{ lib, ... }:

{
  # 每次 switch 之后自动执行的命令
  home.activation.activation_check =
    lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
      echo "home-manager activated"
      check_cmd() {
        local cmd="$1"
  
        if command -v "$cmd" >/dev/null 2>&1; then
          echo "[OK] command found: $cmd"
        else
          printf '\033[30;43m[WARNING]\033[0m command not found: %s\n' "$cmd"
        fi
      }
  
      check_service() {
        local service="$1"
  
        if [ -f "/etc/systemd/system/$service" ]; then
          echo "[OK] service found: $service"
        else
          printf '\033[30;43m[WARNING]\033[0m service missing: %s\n' "$service"
        fi
      }

      check_non_nixos_gpu() {
        if [ -L /etc/tmpfiles.d/non-nixos-gpu.conf ]; then
          echo "[OK] non-nixos-gpu-setup has been run"
        else
          printf '\033[30;43m[WARNING]\033[0m run: sudo non-nixos-gpu-setup\n'
        fi
      }
  
      echo "=========================================="
      echo "===== Home Manager Environment Check ====="
      echo "=========================================="
  
      check_cmd niri
      check_cmd qutebrowser
  
      check_service mouseless.service
      check_service singbox.service

      check_non_nixos_gpu
  
      echo "=========================================="
      echo "=========================================="
    '';
}
