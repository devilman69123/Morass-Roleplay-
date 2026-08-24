#!/usr/bin/env python3
"""FTP deploy fallback when lftp is not installed."""

from __future__ import annotations

import ftplib
import sys
from pathlib import Path


def load_config(path: Path) -> dict[str, str]:
    config: dict[str, str] = {}
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        config[key.strip()] = value.strip()
    return config


def ensure_dir(ftp: ftplib.FTP, remote_dir: str) -> None:
    parts = [p for p in remote_dir.replace("\\", "/").split("/") if p]
    current = ""
    for part in parts:
        current = f"{current}/{part}" if current else part
        try:
            ftp.mkd(current)
        except ftplib.error_perm:
            pass


def upload_tree(ftp: ftplib.FTP, local: Path, remote: str, exclude_names: set[str]) -> None:
    ensure_dir(ftp, remote)
    for item in sorted(local.iterdir()):
        if item.name in exclude_names or item.name == ".git":
            continue
        remote_path = f"{remote}/{item.name}"
        if item.is_dir():
            upload_tree(ftp, item, remote_path, exclude_names)
        else:
            with item.open("rb") as handle:
                ftp.storbinary(f"STOR {remote_path}", handle)
            print(f"  uploaded {remote_path}")


def main() -> None:
    if len(sys.argv) != 2:
        print("Usage: deploy-ftp.py <deploy.config>")
        sys.exit(1)

    config = load_config(Path(sys.argv[1]))
    host = config.get("FTP_HOST")
    port = int(config.get("FTP_PORT", "21"))
    user = config.get("FTP_USER")
    password = config.get("FTP_PASSWORD")
    remote_gamemodes = config.get("FTP_REMOTE_GAMEMODES", "garrysmod/gamemodes")
    remote_cfg = config.get("FTP_REMOTE_CFG", "garrysmod/cfg")
    remote_addons = config.get("FTP_REMOTE_ADDONS", "garrysmod/addons")

    if not all([host, user, password]):
        print("FTP_HOST, FTP_USER, and FTP_PASSWORD are required in deploy.config")
        sys.exit(1)

    repo_root = Path(__file__).resolve().parent.parent
    exclude = {".git", ".gitmodules"}

    ftp = ftplib.FTP()
    ftp.connect(host, port, timeout=60)
    ftp.login(user, password)

    print("Uploading helix...")
    upload_tree(ftp, repo_root / "gamemodes/helix", f"{remote_gamemodes}/helix", exclude)
    print("Uploading morass schema...")
    upload_tree(ftp, repo_root / "gamemodes/morass", f"{remote_gamemodes}/morass", exclude)
    print("Uploading cfg...")
    upload_tree(ftp, repo_root / "cfg", remote_cfg, exclude)
    print("Uploading addons...")
    upload_tree(ftp, repo_root / "addons", remote_addons, exclude)

    ftp.quit()


if __name__ == "__main__":
    main()
