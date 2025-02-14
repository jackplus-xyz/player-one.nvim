fn main() {
    #[cfg(target_os = "macos")]
    {
        // Add both x86_64 and arm64 library paths
        println!("cargo:rustc-link-search=/opt/homebrew/lib");
        println!("cargo:rustc-link-search=/usr/local/lib");

        // Link against LuaJIT instead of Lua
        println!("cargo:rustc-link-lib=dylib=luajit-5.1");
    }

    // delete existing version file created by downloader
    let _ = std::fs::remove_file("target/release/version");
    // get current sha from git
    let output = std::process::Command::new("git")
        .args(["rev-parse", "HEAD"])
        .output()
        .unwrap();
    let sha = String::from_utf8(output.stdout).unwrap();

    // write to version
    std::fs::create_dir_all("target/release").unwrap();
    std::fs::write("target/release/version", sha.trim()).unwrap();
}
