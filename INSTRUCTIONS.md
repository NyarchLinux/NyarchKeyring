# Nyarch Keyring Instructions

## What is this repo

This is the GPG keyring package for the Nyarch Linux repository. It contains the PGP keys used to verify signed packages. It follows the same structure as `archlinux-keyring`.

When users install `nyarch-keyring`, the following files are placed in `/usr/local/share/pacman/keyrings/`:

- `nyarch.gpg` — the keyring containing all master, packager, and revoked packager keys
- `nyarch-trusted` — owner trust database marking master keys as fully trusted
- `nyarch-revoked` — list of revoked key fingerprints

The key hierarchy is:

- **Master keys** (`master-keyids`) — top-level keys that sign and trust packager keys
- **Packager keys** (`packager-keyids`) — keys used by maintainers to sign packages
- **Revoked packager keys** (`packager-revoked-keyids`) — keys that have been revoked

## How to create a GPG key

If you do not already have a GPG key, generate one:

```bash
gpg --full-generate-key
```

Select:
- Key type: RSA and RSA (default)
- Key size: 4096 bits (recommended)
- Expiration: set as needed (1y, 2y, or 0 for no expiration)
- Enter your name and email address

Once generated, export your public key:

```bash
gpg --armor --export <KEY_ID> > mykey.asc
```

Publish your key to a keyserver so others can retrieve it:

```bash
gpg --send-keys <KEY_ID>
```

If you have issues with the default keyserver, try:

```bash
gpg --keyserver hkps://keys.openpgp.org --send-keys <KEY_ID>
```

## How to add a packager key

### If you are a master key holder

1. Add the packager's key ID to `packager-keyids`, one per line:

   ```
   <PACKAGER_KEY_ID>
   ```

2. Run the `update-keys` script to regenerate the keyring:

   ```bash
   ./update-keys
   ```

   This will fetch the key from a keyserver, verify it is fully trusted, export it, and update `nyarch.gpg`.

3. Commit and push the changes.

### If you are not a master key holder

1. Generate your key (see above) and publish it to a keyserver.
2. Open a PR or contact a master key holder to have your key ID added to `packager-keyids`.
3. A master key holder will run `update-keys` to sign your key and update the keyring.

### To add a new master key

1. Add the key ID and name to `master-keyids`:

   ```
   <KEY_ID> <Name>
   ```

2. Run `./update-keys`. The script will import, sign, and export the key, and update `nyarch-trusted`.

## How to export and import your private key

### Export private key

Export your private key to an encrypted file:

```bash
gpg --armor --export-secret-keys <KEY_ID> > private-key.asc
```

### Import private key

Import your private key on another machine:

```bash
gpg --import private-key.asc
```

After importing, verify it works:

```bash
gpg --list-secret-keys
```

To allow the key to be used for signing without prompting for a passphrase every time (not recommended unless the machine is secure), you can set the trust level:

```bash
gpg --edit-key <KEY_ID>
```

Then type `trust`, select `5` (ultimate), and type `quit`.

## How to sign packages with your key

Add the following to your `~/.makepkg.conf`:

```ini
GPGKEY="<YOUR_KEY_ID>"
```

Then build your package normally:

```bash
makepkg -s
```

The package will be signed automatically and produce a `.sig` file alongside the `.pkg.tar.zst` file.

To sign an already-built package manually:

```bash
gpg --detach-sign --use-agent <package-file>.pkg.tar.zst
```

### Verifying a signed package

```bash
gpg --verify <package-file>.pkg.tar.zst.sig
```
