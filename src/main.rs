use structopt::StructOpt;
use std::path::{PathBuf, Path};
use std::collections::HashSet;

#[derive(StructOpt,Debug)]
struct Opt {
    #[structopt(short, long, parse(from_os_str))]
    master: PathBuf,
    #[structopt(short, long, parse(from_os_str))]
    branch: PathBuf,
    #[structopt(short, long)]
    rec: bool

}

struct SubPath {
    file_path: HashSet<PathBuf>,
    dir_path: HashSet<PathBuf>,
    parent_path: PathBuf,
}

impl SubPath {
    fn from_parent(path: impl AsRef<Path>) -> Self {

    }
}

fn main() {
    let opt = Opt::from_args();
    println!("{:?}", opt);
}
