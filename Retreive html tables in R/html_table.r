# Claas Heuer, August 2015
#
# links:
# https://cran.r-project.org/web/packages/XML/XML.pdf
# http://www.inside-r.org/packages/cran/XML/docs/readHTMLTable
# http://gastonsanchez.com/work/webdata/getting_web_data_r4_parsing_xml_html.pdf
# 
# first we need XML
# sudo apt-get install libxml2-dev
# install.packages('XML')

# we will download a list of animals from vit

# https://service.vit.de/inter-bull/Front?aktion=ErzeugeStartSeite

# make the query and save the source (chrome: "view page source") to
# a file (e.g. test.html)

library(XML)

a <- htmlParse("test.xml",useInternalNodes = TRUE)

c <- readHTMLTable(a, stringsAsFactors=FALSE)





