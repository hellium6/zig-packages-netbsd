$NetBSD$

--- ELF/Config.h.orig	2025-01-14 09:41:02.000000000 +0000
+++ ELF/Config.h
@@ -247,6 +247,7 @@ struct Config {
   bool enableNonContiguousRegions;
   bool executeOnly;
   bool exportDynamic;
+  bool fixCortexA53Errata835769;
   bool fixCortexA53Errata843419;
   bool fixCortexA8;
   bool formatBinary = false;
