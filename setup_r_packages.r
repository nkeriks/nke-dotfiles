#!/usr/bin/env Rscript

required <- c('devtools', 'stringr')
for (pk in required) {
  if (!requireNamespace(pk, quietly=TRUE)) {
    install.packages(pk)
  }
}


is_installed <- function(pkg_names) {
  pkg_names %in% installed.packages()[,1]
}

pkgs <- read.table("R_packages")
names(pkgs) <- 'package_string'
pkgs$package_name <- unlist(lapply(stringr::str_split(pkgs$package_string, '/'), tail, 1))

pkgs$need_install <- !is_installed(pkgs$package_name)

pkgs$from_github <- grepl('/', pkgs$package_string)
pkgs$need_install_cran <- pkgs$need_install & !pkgs$from_github
pkgs$need_install_github <- pkgs$need_install & pkgs$from_github
print(pkgs)

message(sprintf("Installing %d new packages: %s",
                sum(pkgs$need_install),
                paste(pkgs$package_name[pkgs$need_install],
                      collapse=' ')))

if (any(pkgs$need_install_cran)) {
    install.packages(pkgs$package_name[pkgs$need_install_cran])
}

if (any(pkgs$need_install_github)) {
    devtools::install_github(pkgs$package_string[pkgs$need_install_github])
}

pkgs$final_installed <- is_installed(pkgs$package_name)
if (!all(pkgs$final_installed)) {
    message("Install failed for: ", paste(pkgs$package_name[!pkgs$final_installed], collapse=' '))
}

