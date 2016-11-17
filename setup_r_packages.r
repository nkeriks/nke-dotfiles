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

pkgs <- read.table("R_packages", stringsAsFactors=FALSE)
names(pkgs) <- 'package_string'

# wesm/feather/R --> feather
get_name <- function(nm) {
    ifelse(length(nm) == 1, nm, nm[2])
}

pkgs <- pkgs %>%
    dplyr::mutate(package_name=sapply(stringr::str_split(package_string, '/|:'), get_name),
           need_install=!is_installed(package_name))


message(sprintf("Installing %d new packages: %s",
                sum(pkgs$need_install),
                paste(pkgs$package_name[pkgs$need_install],
                      collapse=', ')))

installer <- function(pkg_string) {
    message("installing ", pkg_string)
    if (stringr::str_detect(pkg_string, ':')) {
        message("from bioconductor")
        if (!exists("biocLite")) {
            source("https://bioconductor.org/biocLite.R")
        }
        biocLite(stringr::str_split_fixed(pkg_string, ':', 2)[1,2])
    } else if (stringr::str_detect(pkg_string, '/')) {
        message("from github")
        devtools::install_github(pkg_string)
    } else {
        message("from CRAN")
        install.packages(pkg_string, dependencies=TRUE)
    }
}

tmp <- pkgs %>% dplyr::filter(need_install) %>% `[[`('package_string') %>%  sapply(installer)

pkgs$final_installed <- is_installed(pkgs$package_name)

if (!all(pkgs$final_installed)) {
    message("Install failed for: ", paste(pkgs$package_name[!pkgs$final_installed], collapse=' '))
}
