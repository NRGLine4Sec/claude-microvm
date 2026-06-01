{ pkgs, ... }:
let
  nodejs = pkgs.nodejs_22;
  pi-coding-agent = pkgs.buildNpmPackage rec {
    pname = "pi-coding-agent";
    version = "0.77.0";

    src = pkgs.fetchFromGitHub {
      owner = "earendil-works";
      repo = "pi";
      rev = "v${version}";
      hash = "sha256-PJyhLWfqoPjHoYl4pKJVD3uMD5YjQB5YIk5mBZvGi8E=";
    };

    npmDepsHash = "sha256-X0qMLqAi5pgrtTw5+DfSPsgIEngUnHwGxqYE6PL8NJU=";

    inherit nodejs;

    # The generate-models/generate-image-models scripts fetch from external APIs
    # (OpenRouter, AI Gateway, etc.) which are unavailable in the Nix sandbox.
    # Patch them out so the build uses the committed generated files directly.
    postPatch = ''
      substituteInPlace packages/ai/package.json \
        --replace-fail '"build": "npm run generate-models && npm run generate-image-models && tsgo -p tsconfig.build.json"' \
                       '"build": "tsgo -p tsconfig.build.json"'
    '';

    # Build all workspace packages (tui -> ai -> agent -> coding-agent)
    npmBuildScript = "build";
    dontNpmInstall = true;

    nativeBuildInputs = [ pkgs.makeWrapper pkgs.pkg-config pkgs.python3 ];
    buildInputs = [ pkgs.cairo pkgs.pango pkgs.pixman pkgs.giflib pkgs.libjpeg ];

    installPhase = ''
      runHook preInstall

      npm prune --production --ignore-scripts

      mkdir -p $out/lib/pi $out/bin
      cp -r packages node_modules $out/lib/pi/

      makeWrapper ${nodejs}/bin/node $out/bin/pi \
        --add-flags "$out/lib/pi/packages/coding-agent/dist/cli.js"

      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Interactive coding agent CLI";
      homepage = "https://github.com/earendil-works/pi";
      license = licenses.mit;
      mainProgram = "pi";
    };
  };
in
{
  claude-vm.agent = {
    name = "pi";
    launchCommand = "pi";
    extraPackages = [ pi-coding-agent ];
    shellInit = "";
  };
}
