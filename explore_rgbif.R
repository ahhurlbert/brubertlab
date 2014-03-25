### This script explores the interface between R and GBIF for species distribution modeling

install.packages('dichromat')
install.packages('rgbif')
install.packages('dismo')

# Load packages

library(dichromat)
library(rgbif)
library(dismo)


#######################################################
### Acquire Data from GBIF 


## Use name_lookup() to find names of taxa of interest 
pyrenula = name_lookup('Pyrenula', rank='species', limit=1000, status='accepted')
pyrenula = name_lookup('Pyrenula', rank='species', limit=1000, status='accepted')$data


bftuna = name_lookup('Thunnus thynnus', rank='species', limit=1000, status='accepted')$data

bfsp = subset(bftuna, phylum=='Chordata')$nubKey

# Keep only species in Pyrenula genus
pyrenula = subset(pyrenula, parent=='Pyrenula')

# Sometimes taxa are classified in different ways
unique(pyrenula[,c('parent','parentKey','kingdom','phylum','clazz','order','family')])

# Get list of species numeric keys for Pyrenula
pyrenula_sp = pyrenula[,c('nubKey','canonicalName')]; dim(pyrenula_sp)
pyrenula_sp = unique(pyrenula_sp); dim(pyrenula_sp)

# Make dataframe of number of records for each species
pyrenula_sp$numRec = sapply(pyrenula_sp$nubKey, function(x) occ_count(nubKey=x))


bfsp 

# Which species have the most records?
pyrenula_sp = pyrenula_sp[order(pyrenula_sp$numRec, decreasing=T),]

# Get occurence records for the top 10 most abundant species
use_sp = pyrenula_sp[1:10,'nubKey']


# Search GBIF records- only georeferenced with no spatial issues
pyrenula10_recs = occ_search(taxonKey=use_sp[1], spatialIssues=F, georeferenced=T,
	return='data', fields='minimal', limit=500)
names(pyrenula10_recs) # use to choose which fields wanted


# Bluefin tuna
bfsp = unique(bfsp)

myrecs = data.frame()
for(i in 1:length(bfsp)){
	newdata = occ_search(taxonKey=bfsp[i],spatialIssues=F, georeferenced=T,
		return='data', fields='minimal', limit=500)
	myrecs = rbind(myrecs, newdata)
}

library(maps)
map('world')
points(myrecs$longitude, myrecs$latitude)


library(sp)
p_sp = pyrenula10_recs
coordinates(p_sp) = c('longitude','latitude')
gbifmap(pyrenula10_recs)

# For genus Pyrenula 
p_key <- name_backbone(name='Pyrenula'); p_key
p_key <- name_backbone(name='Pyrenula')$genusKey


#
mykey  = name_backbone(name='Dipodomys')$genusKey

occ_count(nubKey=mykey)
Dip_recs = occ_search(taxonKey=mykey, georeferenced=T, spatialIssues=F,limit=1000, return='data')


pcruenta = occ_search(taxonKey=3468021, spatialIssues=F, georeferenced=T) 
gbifmap(Dip_recs)

pyrenula_recs = occ_search(taxonKey=2598842, spatialIssues=F, georeferenced=T)

