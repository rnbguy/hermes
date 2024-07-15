{ nixpkgs }:
let
  rustWithWasmTarget =
    nixpkgs.rust-bin.stable.latest.default.override
      {
        targets = [ "wasm32-unknown-unknown" ];
      };

  rustWasmPlatform = nixpkgs.makeRustPlatform {
    cargo = rustWithWasmTarget;
    rustc = rustWithWasmTarget;
  };
in
rustWasmPlatform.buildRustPackage {
  name = "ibc-client-tendermint-cw";

  src = nixpkgs.fetchFromGitHub {
    owner = "cosmos";
    repo = "ibc-rs";
    rev = "8f4661bda3357045b373ad23b4ee98d191c6a1f9";
    hash = "sha256-inQ3npOzAdgqV6/9tl8TcLwToR7q3zA7+77yFzilzRY=";
  };

  cargoLock = {
    lockFile = ./ibc-rs.Cargo.lock;
  };

  postPatch = ''
    ln -s ${./ibc-rs.Cargo.lock} Cargo.lock
  '';

  doCheck = false;

  buildPhase = ''
    RUSTFLAGS='-C link-arg=-s' cargo build -p ibc-client-tendermint-cw --target wasm32-unknown-unknown --release --lib --locked
  '';

  installPhase = ''
    mkdir -p $out
    cp target/wasm32-unknown-unknown/release/ibc_client_tendermint_cw.wasm $out/
  '';
}
