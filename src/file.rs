use async_std::fs;
use async_std::prelude::*;
use futures::future::FutureExt;
use std::future::Future;

use failure::{format_err, Fallible};
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

macro_rules! path_push {
    ($parent: expr, $sub: expr) => {{
        let mut parent = $parent.clone();
        parent.push($sub.as_ref());
        parent
    }};
}

macro_rules! get_fut_fd {
    ($p: expr) => {{
        let md = match async_std::fs::metadata(&$p).await {
            Err(_) => return false,
            Ok(md) => md,
        };

        let mut buf = vec![0u8; md.len() as usize];
        let fd = match fs::File::open(&$p).await {
            Err(_) => return false,
            Ok(fd) => fd,
        };
        (fd, buf)
    }};
}

//trait FileFiltor<P: AsRef<Path>> {
//    fn is_select(&self, p: P) -> bool;
//}

trait FileFilter {
    fn is_select(&self, p: &Path) -> bool;
}
enum DiffStatus {
    Add(PathBuf),
    Delete(PathBuf),
    Changed(PathBuf),
}

struct DefaultFiltor {
    magic_cookie: Option<Cookie>,
}

struct BlackExtFiltor(Vec<OsString>);
struct WhiteExtFiltor(Vec<OsString>);

pub struct DirComare {
    opt: Opt,
    mcookie: Option<Cookie>,
    filter: Vec<Box<dyn FileFilter>>,
}
pub struct CompareBuilder(Opt);

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

impl FileFilter for BlackExtFiltor {
    fn is_select(&self, p: &Path) -> bool {
        !contain_extension!(self.0, p)
    }
}

impl FileFilter for WhiteExtFiltor {
    fn is_select(&self, p: &Path) -> bool {
        contain_extension!(self.0, p)
    }
}

// 公有
impl DirComare {
    fn run() {}

    pub fn is_select(&self, p: impl AsRef<Path>) -> bool {
        let p = p.as_ref();
        for f in self.filter.iter() {
            if !f.is_select(p) {
                return false;
            }
        }
        true
    }

    async fn is_diff(&self, sub_path: impl AsRef<Path>) -> bool {
        let p1 = path_push!(self.opt.base, sub_path);
        let p2 = path_push!(self.opt.branch, sub_path);

        let (fd1, buf1) = get_fut_fd!(p1);
        let (fd2, buf2) = get_fut_fd!(p2);

        futures::join!(fd1, fd2);

        false
    }

    async fn visit_dir(parent: PathBuf, f: &mut impl FnMut(PathBuf)) {
        let fut = async move {
            let mut dir = fs::read_dir(parent).await.unwrap();
            for entry in dir.next().await {
                if let Ok(entry) = entry {
                    let path = entry.path();
                    if path.is_dir() {
                        Self::visit_dir(path, f).await;
                    } else {
                        f(path);
                    }
                }
            }
        };
        fut.await;
    }

    //async fn visit_dir(parent: PathBuf) {
    //        let mut dir = fs::read_dir(parent).await.unwrap();
    //        for entry in dir.next().await {
    //            if let Ok(entry) = entry {
    //                let path = entry.path();
    //                if path.is_dir() {
    //                    Box::new(Self::visit_dir(path).await);
    //                } else {
    //                    //f(path);
    //                }
    //            }
    //        }
    //}

    //    async fn visit_dir<F>(parent: impl AsRef<Path>, f: &mut F) -> Fallible<()>
    //    where
    //        F: FnMut(PathBuf),
    //    {
    //        let parent = parent.as_ref();
    //        let mut dir = fs::read_dir(parent).await?;
    //        for entry in dir.next().await {
    //            if let Ok(entry) = entry {
    //                let path = entry.path();
    //                if path.is_dir() {
    //    //                Box::new(Self::visit_dir(&path, f)).await?;
    //                    Box::new(Self::visit_dir(&path, f).await?);
    //                } else {
    //                    f(path);
    //                }
    //            }
    //        }
    //        Ok(())
    //    }
}

impl CompareBuilder {
    fn with(opt: Opt) -> Self {
        Self(opt)
    }

    fn build_dir_compare(self) -> DirComare {
        let filter = Self::get_filters(&self.0);
        DirComare {
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
