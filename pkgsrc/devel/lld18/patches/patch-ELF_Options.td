$NetBSD$

--- ELF/Options.td.orig	2024-06-15 17:21:32.000000000 +0000
+++ ELF/Options.td
@@ -233,6 +233,9 @@ defm filter: Eq<"filter", "Set DT_FILTER
 
 defm fini: Eq<"fini", "Specify a finalizer function">, MetaVarName<"<symbol>">;
 
+def fix_cortex_a53_835769: F<"fix-cortex-a53-835769">,
+  HelpText<"Apply fixes for AArch64 Cortex-A53 erratum 835769">;
+
 def fix_cortex_a53_843419: F<"fix-cortex-a53-843419">,
   HelpText<"Apply fixes for AArch64 Cortex-A53 erratum 843419">;
 
