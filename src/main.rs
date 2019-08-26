mod file;

use failure::{format_err, Fallible};
use std::collections::HashSet;
use std::fs;
use std::io::Read;
use std::path::{Path, PathBuf};
use structopt::StructOpt;
use std::ffi::OsString;

use magic::{flags::*, Cookie};

#[derive(StructOpt, Debug)]
pub struct Opt {
    #[structopt(short, long, parse(from_os_str))]
    base: PathBuf,
    #[structopt(short, long, parse(from_os_str))]
    branch: PathBuf,
    #[structopt(short, long)]
    rec: bool,
    #[structopt(short, long, parse(from_os_str))]
    black_ft: Vec<OsString>,
    #[structopt(short, long, parse(from_os_str))]
    white_ft: Vec<OsString>,
    #[structopt(short, long)]
    filters: Vec<String>,
}

struct App {
    opt: Opt,
    magic_cookie: Cookie,
}

impl App {
    fn new() -> Fallible<Self> {
        let opt = Opt::from_args();
        let magic_cookie = Self::init_magic_cookie()?;
        Ok(Self { opt, magic_cookie })
    }

    fn init_magic_cookie() -> Fallible<Cookie> {
        let cookie = Cookie::open(MIME).unwrap();
        let database = vec!["/usr/share/file/misc/magic.mgc"];
        cookie.load(&database)?;
        Ok(cookie)
    }

    fn visit_dir<F>(parent: impl AsRef<Path>, f: &mut F) -> Fallible<()>
    where
        F: FnMut(PathBuf),
    {
        let parent = parent.as_ref();
        for entry in fs::read_dir(parent)? {
            let entry = entry
                .map_err(|err| format_err!("entry err: {}, parent: {}", err, parent.display()))?;
            let path = entry.path();
            if path.is_dir() {
                Self::visit_dir(&path, f)?;
            } else {
                f(path);
            }
        }
        Ok(())
    }

    fn find_diff(&self) -> Fallible<()> {
        Ok(())
    }
}

enum CompareDiff {
    Add(PathBuf),
    Changed(PathBuf),
    Delete(PathBuf),
}

struct DirSubPath<'a> {
    magic_cookie: &'a Cookie,
    parent: PathBuf,
    subs: HashSet<PathBuf>,
}

impl<'a> DirSubPath<'a> {
    fn new(parent: PathBuf, magic_cookie: &'a Cookie) -> Fallible<Self> {
        let dir = parent
            .canonicalize()
            .map_err(|err| format_err!("{} canonicalize err {}", parent.display(), err))?;

        if dir == PathBuf::from("/") {
            return Err(format_err!("{} is root dir", dir.display()));
        }

        let md = fs::metadata(&dir)
            .map_err(|err| format_err!("{} metadata err: {}", dir.display(), err))?;
        if !md.is_dir() {
            return Err(format_err!("{} is not dir", dir.display()));
        }

        let subs = HashSet::new();

        let mut dsp = Self { magic_cookie, parent, subs };

        App::visit_dir(&dir, &mut |path| {
            if !dsp.is_text_file(&path) {
                return
            }
            let path = path.strip_prefix(&dir).unwrap();
            dsp.subs.insert(path.to_path_buf());
        })
        .map_err(|err| format_err!("visit {} err {}", dir.display(), err))?;

        Ok(dsp)
    }

    fn compare(&self, other: &Self) -> Vec<CompareDiff> {
        let mut vec = Vec::new();
        for sub in self.subs.iter() {
            if !other.subs.contains(sub) {
                vec.push(CompareDiff::Add(sub.clone()));
                continue;
            }

            let file1 = self.parent.join(sub);
            let file2 = other.parent.join(sub);
            if !Self::file_is_eq(&file1, &file2) {
                vec.push(CompareDiff::Changed(sub.clone()));
            }
        }
        for sub in other.subs.iter() {
            if !self.subs.contains(sub) {
                vec.push(CompareDiff::Delete(sub.clone()))
            }
        }
        vec
    }

    fn file_is_eq(file1: impl AsRef<Path>, file2: impl AsRef<Path>) -> bool {
        let file1 = file1.as_ref();
        let file2 = file2.as_ref();

        let md1 = match fs::metadata(file1) {
            Err(_) => return false,
            Ok(md) => md,
        };
        let md2 = match fs::metadata(file2) {
            Err(_) => return false,
            Ok(md) => md,
        };

        if md1.len() != md2.len() {
            return false;
        }

        let mut f1 = match fs::File::open(file1) {
            Err(_) => return false,
            Ok(f) => f,
        };

        let mut buf1: [u8; 1024] = [0u8; 1024];
        f1.read(&mut buf1);

        //md.file_type()
        true
    }

    fn is_text_file(&self, p: impl AsRef<Path>) -> bool {
        let mime = match self.magic_cookie.file(p.as_ref()) {
            Err(_) => return false,
            Ok(mime) => mime,
        };
        if mime.contains("text/plain") {
            return true;
        }
        false
    }
}

fn main() -> Fallible<()> {
    let app = App::new()?;
    app.find_diff()
}
