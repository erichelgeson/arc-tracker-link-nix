{
  description = "ARC Tracker Link AppImage wrapped for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pname = "arc-tracker-link";
      version = "2.1.8";
      src = pkgs.fetchurl {
        url = "https://cdn.arctracker.io/link/linux/ARC-Tracker-Link-${version}-x86_64.AppImage";
        hash = "sha256-ERdbVsmIUwK6wA0LQDba0ZKYk6bvr4vXYJLEqYvokUg=";
      };
      contents = pkgs.appimageTools.extractType2 { inherit pname version src; };
    in {
      packages.${system}.default = pkgs.appimageTools.wrapType2 {
        inherit pname version src;
        # The AppImage expects these from the host system instead of bundling them.
        extraPkgs = p: with p; [ webkitgtk_4_1 libsoup_3 gtk3 glib-networking libayatana-appindicator dbus ];
        # Link writes its own URL handler to ~/.local/share/applications on start. It uses
        # $APPIMAGE as the Exec path when set, so point that at this wrapper instead of
        # the bare binary inside it, which can't find WebKitGTK on its own.
        extraInstallCommands = ''
          mv $out/bin/${pname} $out/bin/.${pname}-fhs
          cat > $out/bin/${pname} <<EOF
          #!${pkgs.runtimeShell}
          export APPIMAGE=$out/bin/${pname}
          exec $out/bin/.${pname}-fhs "\$@"
          EOF
          chmod +x $out/bin/${pname}
          install -Dm444 ${contents}/arctracker-link.desktop $out/share/applications/arctracker-link.desktop
          substituteInPlace $out/share/applications/arctracker-link.desktop \
            --replace-fail 'Exec=arctracker-link' 'Exec=${pname}'
          cp -r ${contents}/usr/share/icons $out/share/
        '';
        meta = {
          description = "Links your ARC Raiders account to ARC Tracker";
          homepage = "https://arctracker.io/app";
          license = pkgs.lib.licenses.unfree;
          platforms = [ system ];
          mainProgram = pname;
        };
      };
    };
}
