#!/usr/bin/env Rscript

not_installed <- function(pkgs) {
    setdiff(pkgs, installed.packages()[,1])
}


pkgs <- read.table("R_packages")$V1
to_install <- not_installed(pkgs)
message(sprintf("Installing %d new packages: %s", length(to_install), paste(to_install, collapse=' ')))
install.packages(to_install)

missing <- not_installed(pkgs)
message("Install failed for: ", paste(missing, collapse=' '))

