{ pkgs, ... }:
{
  claude-vm.agent = {
    name = "codex";
    launchCommand = "codex";
    # renovate: datasource=npm depName=@openai/codex
    # version: 0.135.0
    extraPackages = [ pkgs.codex ];
    shellInit = "";
  };
}
