{ pkgs, ... }:
{
  claude-vm.agent = {
    name = "gemini";
    launchCommand = "gemini";
    # renovate: datasource=npm depName=@google/gemini-cli
    # version: 0.44.1
    extraPackages = [ pkgs.gemini-cli ];
    shellInit = "";
  };
}
