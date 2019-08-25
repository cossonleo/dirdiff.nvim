use async_std::fs;

use magic::{flags::*, Cookie};

use std::ffi::OsString;
use std::path::{Path, PathBuf};

use crate::Opt;

macro_rules! contain_extension {
    ($v: expr, $path: expr) => {{
        let p = $path.as_ref();
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

trait FileFiltor<P: AsRef<Path>> {
    fn is_select(&self, p: P) -> bool;
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

impl<P: AsRef<Path>> FileFiltor<P> for DefaultFiltor {
    fn is_select(&self, p: P) -> bool {
        let p = p.as_ref();
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

impl<P: AsRef<Path>> FileFiltor<P> for BlackExtFiltor {
    fn is_select(&self, p: P) -> bool {
        !contain_extension!(self.0, p)
    }
}

struct WhiteExtFiltor(Vec<OsString>);

impl<P: AsRef<Path>> FileFiltor<P> for WhiteExtFiltor {
    fn is_select(&self, p: P) -> bool {
        contain_extension!(self.0, p)
    }
}

pub struct DirComare<P: AsRef<Path>> {
    opt: Opt,
    mcookie: Option<Cookie>,
    filter: Vec<Box<dyn FileFiltor<P>>>,
}

// 公有
impl<P: AsRef<Path>> DirComare<P> {
    pub fn new(opt: Opt) -> Self {
        Self {
            opt,
            mcookie: Self::get_magic_cookie(),
            filter: Vec::new(),
        }
    }
}

// 私有api
impl<P: AsRef<Path>> DirComare<P> {
    fn get_magic_cookie() -> Option<Cookie> {
        let cookie = Cookie::open(MIME).unwrap();
        let database = vec!["/usr/share/file/misc/magic.mgc"];
        match cookie.load(&database) {
            Ok(_) => Some(cookie),
            Err(_) => None,
        }
    }
}

pub struct CompareBuilder<P: AsRef<Path>>(DirComare<P>);

impl<P: AsRef<Path>> CompareBuilder<P> {
    fn new(opt: Opt) -> Self {
        let dc = DirComare::new(opt);
        Self(dc)
    }
}
