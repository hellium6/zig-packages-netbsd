$NetBSD$

--- ELF/Config.h.orig	2024-06-15 17:21:32.000000000 +0000
+++ ELF/Config.h
@@ -234,6 +234,7 @@ struct Config {
   bool enableNewDtags;
   bool executeOnly;
   bool exportDynamic;
+  bool fixCortexA53Errata835769;
   bool fixCortexA53Errata843419;
   bool fixCortexA8;
   bool formatBinary = false;
