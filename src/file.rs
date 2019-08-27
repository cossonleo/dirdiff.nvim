use async_std::fs;

use magic::{flags::*, Cookie};

use std::collections::BTreeSet;
use std::ffi::OsString;
use std::path::{Path, PathBuf};

use crate::Opt;

macro_rules! contain_extension {
    ($v: expr, $path: expr) => {{
        let p = $path;
        let ext = p.extension();
        match ext {
            None => false,
            Some(ext) => {
                let ext = ext.to_os_string();
                let mut has = false;
                for e in $v.iter() {
                    if e == &ext {
                        has = true;
                        break;
                    }
                }
                has
            }
        }
    }};
}

//trait FileFiltor<P: AsRef<Path>> {
//    fn is_select(&self, p: P) -> bool;
//}

trait FileFilter {
    fn is_select(&self, p: &Path) -> bool;
}

struct DefaultFiltor {
    magic_cookie: Option<Cookie>,
}

impl DefaultFiltor {
    fn new() -> Self {
        let cookie = Cookie::open(MIME).unwrap();
        let database = vec!["/usr/share/file/misc/magic.mgc"];
        let magic_cookie = match cookie.load(&database) {
            Ok(_) => Some(cookie),
            Err(_) => None,
        };
        Self { magic_cookie }
    }
}

impl FileFilter for DefaultFiltor {
    fn is_select(&self, p: &Path) -> bool {
        match self.magic_cookie {
            None => p.extension().is_some(),

            Some(ref mc) => {
                let mime = match mc.file(p) {
                    Err(_) => return false,
                    Ok(mime) => mime,
                };
                if mime.contains("text/plain") {
                    return true;
                }
                false
            }
        }
    }
}

struct BlackExtFiltor(Vec<OsString>);

impl FileFilter for BlackExtFiltor {
    fn is_select(&self, p: &Path) -> bool {
        !contain_extension!(self.0, p)
    }
}

struct WhiteExtFiltor(Vec<OsString>);

impl FileFilter for WhiteExtFiltor {
    fn is_select(&self, p: &Path) -> bool {
        contain_extension!(self.0, p)
    }
}

pub struct DirComare {
    opt: Opt,
    mcookie: Option<Cookie>,
    filter: Vec<Box<dyn FileFilter>>,
}

// 公有
impl DirComare {
    pub fn is_select(&self, p: impl AsRef<Path>) -> bool {
        let p = p.as_ref();
        for f in self.filter.iter() {
            if !f.is_select(p) {
                return false;
            }
        }
        true
    }
}

pub struct CompareBuilder(Opt);

impl CompareBuilder {
    fn with(opt: Opt) -> Self {
        Self(opt)
    }

    fn build_dir_compare(self) -> DirComare {
        let filter = Self::get_filters(&self.0);
        DirComare{
            opt: self.0,
            filter,
            mcookie: Self::get_magic_cookie(),
        }
    }

    fn get_filters(opt: &Opt) -> Vec<Box<dyn FileFilter>> {
        let mut filters: Vec<Box<dyn FileFilter>> = Vec::new();
        let mut exists = BTreeSet::new();
        for f in opt.filters.iter() {
            if exists.contains(f) {
                continue;
            }
            exists.insert(f);
            if f == "default" {
                filters.push(Box::new(DefaultFiltor::new()));
            } else if f == "white" {
                filters.push(Box::new(WhiteExtFiltor(opt.white_ft.clone())));
            }
        }
        filters
    }

    fn get_magic_cookie() -> Option<Cookie> {
        let cookie = Cookie::open(MIME).unwrap();
        let database = vec!["/usr/share/file/misc/magic.mgc"];
        match cookie.load(&database) {
            Ok(_) => Some(cookie),
            Err(_) => None,
        }
    }
}
