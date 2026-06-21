{ pkgs, ... }:
{
  # ─── Ollama — Local LLM inference server ─────────────────────────────────────
  #
  # Hardware: Framework 13, AMD Ryzen AI 9 HX 370
  #   - iGPU:  Radeon 890M (Strix Point, gfx1150 / RDNA 3.5)
  #   - RAM:   Up to 96 GB DDR5 unified memory (iGPU shares this pool)
  #   - NPU:   AMD XDNA 2 (50 TOPS) — not yet supported by Ollama
  #
  # Backend: Vulkan (Mesa RADV)
  #   - Vulkan beats ROCm on gfx1150 iGPUs (~14 tok/s vs ~13 tok/s)
  #   - Mesa RADV natively supports gfx1150 — no HSA_OVERRIDE_GFX_VERSION hack
  #   - OLLAMA_IGPU_ENABLE=1 required: Ollama silently drops iGPUs with Vulkan
  #   - Standard pkgs.ollama includes Vulkan support (no -rocm suffix needed)
  #
  # Recommended models (pull with: ollama pull <name>)
  #
  #   Fast + quality:    qwen3:14b            ~9 GB  — thinking mode, great all-rounder
  #   Fast reasoning:    deepseek-r1:8b       ~5 GB  — R1 chain-of-thought, low latency
  #   Best overall:      qwen3.6:27b          ~17 GB — 77% SWE-bench, thinks by default
  #   Best coder:        devstral-small:24b   ~15 GB — best agentic/multi-file coding
  #   MoE sweet spot:    qwen3.6:35b-a3b      ~24 GB — 3B active params, 35B quality
  #   Multimodal:        gemma4:26b           ~16 GB — vision + text, Google Gemma 4
  #   Huge (CPU+iGPU):   qwen3:72b            ~43 GB — frontier quality, fits in RAM
  #
  #   NOTE: qwen3.6 only has 27b and 35b-a3b — there is no 14b tag
  # ─────────────────────────────────────────────────────────────────────────────

  services.ollama = {
    enable = true;
    # Standard package includes Vulkan via Mesa — no -rocm suffix
    package = pkgs.ollama;

    environmentVariables = {
      # Keep models loaded indefinitely — 64–96 GB RAM, no reason to evict
      OLLAMA_KEEP_ALIVE = "-1";

      # Vulkan iGPU: Ollama drops integrated GPUs by default, this re-enables it
      OLLAMA_IGPU_ENABLE = "1";

      # Q8 KV cache: halves KV memory with negligible quality loss
      OLLAMA_KV_CACHE_TYPE = "q8_0";

      # Flash attention significantly reduces memory use on long contexts
      OLLAMA_FLASH_ATTENTION = "1";

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
