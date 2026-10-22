# ollama — local LLM inference server (Vulkan, on the AMD iGPU).
{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;

    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "-1";
      OLLAMA_VULKAN = "1";
      OLLAMA_IGPU_ENABLE = "1";
      VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_CONTEXT_LENGTH = "32768";
      OLLAMA_BATCH_SIZE = "128";
      OLLAMA_NUM_PARALLEL = "1";
      HSA_ENABLE_SDMA = "0";
    };
  };

  # TODO: open-webui broken in nixpkgs 20261017 (makeWrapper rejects --set FRONTEND_BUILD_DIR, same wrapper-hook
  # regression as hplip). Re-enable after upstream fix. ollama itself is unaffected.
  # services.open-webui = {
  #   enable = true;
  #   port = 8080;
  #   environment = {
  #     OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
  #     WEBUI_AUTH = "False";
  #     ENABLE_RAG_WEB_SEARCH = "True";
  #     DATA_DIR = "/var/lib/open-webui";
  #   };
  # };

  networking.firewall.allowedTCPPorts = [
    11434
    8080
  ];
}
