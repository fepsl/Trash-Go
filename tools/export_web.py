"""Exporta o jogo com nomes de arquivos que mudam junto com seu conteúdo."""

import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', default='godot', help='Executável do Godot')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    docs = root / 'docs'
    entry = docs / 'index.html'
    old_html = entry.read_text(encoding='utf-8') if entry.exists() else ''
    old_config = re.search(r'const GODOT_CONFIG = (\{[^\n]+\});', old_html)
    old_base = json.loads(old_config.group(1))['executable'] if old_config else None

    subprocess.run([args.godot, '--headless', '--quiet', '--path', str(root),
                    '--export-release', 'Web', str(entry)], check=True)
    digest = hashlib.sha256()
    for extension in ('pck', 'wasm', 'js'):
        with (docs / f'index.{extension}').open('rb') as asset:
            for chunk in iter(lambda: asset.read(1024 * 1024), b''):
                digest.update(chunk)
    base = 'game-' + digest.hexdigest()[:12]
    extensions = ('js', 'pck', 'wasm', 'audio.worklet.js',
                  'audio.position.worklet.js', 'png', 'icon.png', 'apple-touch-icon.png')
    for extension in extensions:
        source = docs / f'index.{extension}'
        if source.exists():
            source.replace(docs / f'{base}.{extension}')
    html = entry.read_text(encoding='utf-8')
    html = html.replace('"executable":"index"', f'"executable":"{base}"')
    html = html.replace('index.', base + '.')
    entry.write_text(html, encoding='utf-8')

    # A página HTML pode continuar em cache após a publicação. Preservar também
    # o build anterior evita 404 nos arquivos que ela ainda está referenciando.
    keep = {base, old_base}
    known_extensions = '|'.join(re.escape(extension) for extension in extensions)
    known_output = re.compile(rf'(game-[0-9a-f]{{12}})\.({known_extensions})(?:\.import)?')
    for asset in docs.iterdir():
        match = known_output.fullmatch(asset.name)
        if match and match.group(1) not in keep and asset.is_file():
            asset.unlink()
    print(f'WEB_EXPORT_OK: {base}')


if __name__ == '__main__':
    main()
