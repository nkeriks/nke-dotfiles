#!/usr/bin/env Rscript

required <- c('devtools', 'stringr', 'dplyr')
for (pk in required) {
  if (!requireNamespace(pk, quietly=TRUE)) {
    install.packages(pk)
  }
}

`%>%` <- dplyr::`%>%`

is_installed <- function(pkg_names) {
  pkg_names %in% installed.packages()[,1]
}

pkgs <- read.table("R_packages")
names(pkgs) <- 'package_string'

pkgs <- pkgs %>%
    dplyr::mutate(package_name=unlist(lapply(stringr::str_split(package_string, '/|:'), tail, 1)),
           need_install=!is_installed(package_name))


message(sprintf("Installing %d new packages: %s",
                sum(pkgs$need_install),
                paste(pkgs$package_name[pkgs$need_install],
                      collapse=', ')))

installer <- function(pkg_string) {
    if (stringr::str_detect(pkg_string, ':')) {
        if (!exists("biocLite")) {
            source("https://bioconductor.org/biocLite.R")
        }
        biocLite(stringr::str_split_fixed(pkg_string, ':', 2)[1,2])
    } else if (stringr::str_detect(pkg_string, '/')) {
        devtools::install_github(package_string)
    } else {
        install.packages(pkg_string)
    }
}

tmp <- sapply(dplyr::filter(pkgs, need_install)$package_string, installer)

pkgs$final_installed <- is_installed(pkgs$package_name)

if (!all(pkgs$final_installed)) {
    message("Install failed for: ", paste(pkgs$package_name[!pkgs$final_installed], collapse=' '))
}

