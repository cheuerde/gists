file_journals <- ReadBib("journals.bib")
dates <- unlist(unique(file_journals$year))[order(unlist(unique(file_journals$year)),decreasing = TRUE)]

#Prints recerences
for (date in dates) {
  cat(paste0("##",date),"\n")
  print(file_journals[list(year=date)],.opts = list(style="markdown",bib.style ="authoryear" ,max.names =10,dashed=FALSE))
  cat("\n")
}