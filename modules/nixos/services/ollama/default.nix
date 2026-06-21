{ pkgs, ... }:
{
  # ─── Ollama — Local LLM inference server ─────────────────────────────────────
  #
  # Hardware: Framework 13, AMD Ryzen AI 9 HX 370
  #   - iGPU:  Radeon 890M (Strix Point, gfx1150 / RDNA 3.5)
  #   - RAM:   Up to 96 GB DDR5 unified memory (iGPU shares this pool)
  #   - NPU:   AMD XDNA 2 (50 TOPS) — not yet supported by Ollama
  #
  # Backend: Vulkan (pkgs.ollama-vulkan)
  #   - pkgs.ollama (standard) ships CPU-only backends on NixOS
  #   - pkgs.ollama-vulkan includes libggml-vulkan.so
  #   - Mesa RADV supports gfx1150 natively — no GFX override needed
  #   - OLLAMA_IGPU_ENABLE=1 required: Ollama drops iGPUs by default
  #   - VK_ICD_FILENAMES must be set explicitly: systemd services don't
  #     inherit session env vars (unlike Steam/games which run as user)
  #
  # Recommended models (pull with: ollama pull <name>)
  #
  #   DAILY DRIVER:      qwen3.6:35b-a3b      ~24 GB — MoE, only 3B active params per
  #                                                    token so generates at 8B speed
  #                                                    but with 35B quality. Best overall.
  #   Fast chat:         qwen3:8b             ~5 GB  — instant responses, no wait
  #   Dense quality:     qwen3.6:27b          ~17 GB — 77% SWE-bench, slower than MoE
  #   Best coder:        devstral-small:24b   ~15 GB — best agentic/multi-file coding
  #   Reasoning:         deepseek-r1:8b       ~5 GB  — fast R1 chain-of-thought
  #   Multimodal:        gemma4:26b           ~16 GB — vision + text, Google Gemma 4
  #
  #   NOTE: qwen3.6 only has 27b and 35b-a3b — there is no 14b tag
  #   NOTE: disable thinking for chat with /no_think prefix or Open WebUI toggle
  # ─────────────────────────────────────────────────────────────────────────────

  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;

    environmentVariables = {
      # Keep models loaded indefinitely — 64–96 GB RAM, no reason to evict
      OLLAMA_KEEP_ALIVE = "-1";

      # Enable Vulkan backend and iGPU (dropped by default)
      OLLAMA_VULKAN = "1";
      OLLAMA_IGPU_ENABLE = "1";

      # Systemd services don't inherit session env — point at the radeon ICD
      # /run/opengl-driver is a stable NixOS symlink, updates with mesa automatically
      VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";

      # Q8 KV cache: halves KV memory with negligible quality loss
      OLLAMA_KV_CACHE_TYPE = "q8_0";

      # Flash attention significantly reduces memory use on long contexts
      OLLAMA_FLASH_ATTENTION = "1";

      # Cap context to 16K — Vulkan sees all 47GB RAM as VRAM and defaults to
      # 262144 context with a 12GB KV cache. 16K covers almost all real use cases
      # and cuts KV cache to ~750MB, significantly improving token speed.
      # Override per-request in Open WebUI if you need longer context.
      OLLAMA_CONTEXT_LENGTH = "16384";

      # Smaller batch size reduces latency on APU (less memory pressure per step)
      OLLAMA_BATCH_SIZE = "256";

      # 2 parallel requests — shared memory architecture, avoid iGPU VRAM thrash
      OLLAMA_NUM_PARALLEL = "2";

      # Disable SDMA to avoid instability on newer APUs
      HSA_ENABLE_SDMA = "0";
    };
  };

  # ─── Open WebUI — local ChatGPT-style frontend ───────────────────────────────
  services.open-webui = {
    enable = true;
    port = 8080;

    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      # No login required on a single-user local machine
      WEBUI_AUTH = "False";
      ENABLE_RAG_WEB_SEARCH = "True";
      DATA_DIR = "/var/lib/open-webui";
    };
  };

  # ─── Firewall ─────────────────────────────────────────────────────────────────
  networking.firewall.allowedTCPPorts = [
    11434 # Ollama API (also reachable from LAN)
    8080  # Open WebUI
  ];
}
