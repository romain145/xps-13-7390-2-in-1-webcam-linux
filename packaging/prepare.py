from pathlib import Path
import hashlib
import re
import tarfile

root = Path(__file__).resolve().parent.parent
archive = root / 'packaging/camera-source.tar.gz'
files = [root / 'Makefile', root / 'dkms.conf']
for directory in ('driver', 'softisp', 'scripts', 'systemd'):
    for path in sorted((root / directory).rglob('*')):
        if path.is_file() and not path.name.endswith('.mod.c') and (
            path.name == 'Makefile' or path.suffix in ('.c', '.h', '.sh', '.service')
        ):
            files.append(path)
with tarfile.open(archive, 'w:gz') as output:
    for path in files:
        output.add(path, arcname='camera/' + str(path.relative_to(root)))
pkgbuild = root / 'packaging/PKGBUILD'
checksum = hashlib.sha256(archive.read_bytes()).hexdigest()
pkgbuild.write_text(re.sub(r"sha256sums=\('[a-f0-9]+'\)",
                          "sha256sums=('" + checksum + "')", pkgbuild.read_text()))
