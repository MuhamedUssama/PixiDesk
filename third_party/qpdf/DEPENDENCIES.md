# QPDF distribution notes

QPDF 12.4.2 is redistributed under Apache-2.0. `LICENSE.txt` and `NOTICE.md` are
upstream notices from the pinned source release, copied without modification.

Official source: https://github.com/qpdf/qpdf/tree/v12.4.2
Official binaries: https://github.com/qpdf/qpdf/releases/tag/v12.4.2

The QPDF license is not a blanket license for its binary dependencies. The
current upstream archives contain the following runtime libraries:

- macOS: libqpdf; remaining dependencies are system libraries.
- Windows MSVC: qpdf30.dll and Microsoft Visual C++ runtime DLLs. Redistribution
  of Microsoft components must follow their applicable redistributable terms.
- Linux: libqpdf, GnuTLS, Nettle/Hogweed, p11-kit, libffi, libidn2, libtasn1,
  libunistring, and libjpeg. These include LGPL components with notice and
  corresponding-source/relinking obligations. System dependencies also need
  checking on the actual target Linux distribution.

The runtime preparation pins upstream binary hashes, but does not manufacture
license clearance or corresponding-source offers for their dependencies.
**Before publishing an installer**, identify exact shipped dependency versions,
include their applicable license/copyright notices, satisfy any source/relinking
obligations, and validate Microsoft redistributable terms. This remains a
release requirement; native macOS development tests do not complete it for
Windows/Linux. If changing the runtime distribution, update this inventory,
archive pins, package manifests, and the notice bundle together.

Upstream dependency/build context:
https://github.com/qpdf/qpdf/blob/v12.4.2/README-what-to-download.md
https://github.com/qpdf/qpdf/tree/v12.4.2/build-scripts
