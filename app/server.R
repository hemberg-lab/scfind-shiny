library(scfind)

path_to_object <- normalizePath("www/data.rds")

path_to_w2v <- "" # Not sure the path to be filled here
path_to_dictionary <- "" # Not sure the path to be filled here




if(grepl("/atacseq/", path_to_object)) {
    server <- scfindShinyServer(object = loadObject("www/data.rds"))
} else {
    if(grepl("/kidney/|/liver/", path_to_object)) {
        dictionary <- scfindQ2loadDictionaries(w2v = paste0(path_to_w2v, "/PubMed-w2v.bin"), dictionary = paste0(path_to_dictionary, "/scfind_dictionary_hs_v1.rds")) # dictionary for human atlas
    } else  {
        dictionary <- scfindQ2loadDictionaries(w2v = paste0(path_to_w2v, "/PubMed-w2v.bin"), dictionary = paste0(path_to_dictionary, "/scfind_dictionary_mm_v1.rds")) # dictionary for mouse atlas
    }
    
    server <- scfindShinyW2VServer(object = loadObject("www/data.rds"), dictionary = dictionary)
}
    

