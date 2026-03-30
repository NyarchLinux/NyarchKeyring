V = $(shell git describe --abbrev=0)
# below grabs the nyarch.gpg and puts it in the keyrings (ln 11, 14, 17, 18, 21)
FILE_PREFIX = nyarch
# Below is close to the dir where the keyring is (ln 10, 11, 14, 15)
PREFIX = /usr/local
# Below is set to TotallyDIO, seems not to be used here.
DEFAULT_KEY = 861A4F44ACF49447

install:
	install -dm755 $(DESTDIR)$(PREFIX)/share/pacman/keyrings/
	install -m0644 ${FILE_PREFIX}{.gpg,-trusted,-revoked} $(DESTDIR)$(PREFIX)/share/pacman/keyrings/

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/share/pacman/keyrings/${FILE_PREFIX}{.gpg,-trusted,-revoked}
	rmdir -p --ignore-fail-on-non-empty $(DESTDIR)$(PREFIX)/share/pacman/keyrings/
dist:
	git archive --format=tar --prefix=${FILE_PREFIX}-keyring-$(V)/ master | gzip -9 > ${FILE_PREFIX}-keyring-$(V).tar.gz
	gpg --default-key ${DEFAULT_KEY} --detach-sign --use-agent ${FILE_PREFIX}-keyring-$(V).tar.gz

upload:
	rsync --chmod 644 --progress ${FILE_PREFIX}-keyring-$(V).tar.gz ${FILE_PREFIX}-keyring-$(V).tar.gz.sig ${FILE_PREFIX}linux.moe:/nginx/var/www/keyring/
#																			^makes signature										^figure this out lol
.PHONY: install uninstall dist upload

