use failure::{format_err, Fallible};
use std::collections::HashSet;
use std::fs;
use std::path::{Path, PathBuf};
use structopt::StructOpt;

#[derive(StructOpt, Debug)]
struct Opt {
    #[structopt(short, long, parse(from_os_str))]
    master: PathBuf,
    #[structopt(short, long, parse(from_os_str))]
    branch: PathBuf,
    #[structopt(short, long)]
    rec: bool,
}

fn visit_dir<F>(parent: impl AsRef<Path>, f: &mut F) -> Fallible<()>
where
    F: FnMut(PathBuf),
{
    for entry in fs::read_dir(parent)? {
        let entry = entry.map_err(|err| format_err!("entry err: {}", err))?;
        let path = entry.path();
        if path.is_dir() {
            visit_dir(&path, f)
                .map_err(|err| format_err!("visit {} err {}", path.display(), err))?;
        } else {
            f(path);
        }
    }
    Ok(())
}

fn file_is_eq(file1: impl AsRef<Path>, file2: impl AsRef<Path>) -> bool {
    true
}

macro_rules! get_sub_path {
    ($dir: expr) => {{
        let dir = $dir
            .canonicalize()
            .map_err(|err| format_err!("{} canonicalize err {}", $dir.display(), err))?;

        if dir == PathBuf::from("/") {
            return Err(format_err!("{} is root dir", dir.display()));
        }

        let md = fs::metadata(&dir)
            .map_err(|err| format_err!("{} metadata err: {}", dir.display(), err))?;
        if !md.is_dir() {
            return Err(format_err!("{} is not dir", dir.display()));
        }

        let mut sub_paths = HashSet::new();
        visit_dir(&dir, &mut |path| {
            let path = path.strip_prefix(&dir).unwrap();
            sub_paths.insert(path.to_path_buf());
        })
        .map_err(|err| format_err!("visit {} err {}", dir.display(), err))?;
        sub_paths
    }};
}

enum SubPath {
    File(PathBuf),
    Dir(PathBuf, Vec<Self>),
}

enum CompareDiff {
    Add(PathBuf),
    Changed(PathBuf),
    Delete(PathBuf),
}

struct DirSubPath {
    parent: PathBuf,
    subs: HashSet<PathBuf>,
}

impl DirSubPath {
    fn new(parent: PathBuf) -> Fallible<Self> {
        let subs = get_sub_path!(parent);
        Ok(Self { parent, subs})
    }

    fn compare(&self, other: &Self) -> Vec<CompareDiff> {
        let vec = Vec::new();
        for sub in self.subs.iter() {
            if !other.subs.contains(sub) {
                vec.push(CompareDiff::Add(sub.clone()));
                continue
            }

            let file1 = self.parent.join(sub);
            let file2 = other.parent.join(sub);
            if !file_is_eq(&file1, &file2) {
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
}

struct DiffTree {
    sub_paths: Vec<SubPath>,
}

impl DiffTree {
    fn new(dir1: PathBuf, dir2: PathBuf) -> Fallible<Self> {
        let sub1 = get_sub_path!(dir1);
        let sub2 = get_sub_path!(dir2);
    }

    fn get_all_path(parent: impl AsRef<Path>) -> Fallible<Vec<SubPath>> {
        let vec = Vec::new();

        for entry in fs::read_dir(parent)? {
            let entry = entry.map_err(|err| format_err!("entry err: {}", err))?;
            let path = entry.path();
        }

        Ok(vec)
    }
}

struct App {}

fn main() {
    let opt = Opt::from_args();
    println!("{:?}", opt);
}
