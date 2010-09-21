# Edit according to your needs
SHELL=/bin/bash

PROGRAM = lazar 
FEAT_GEN = rex linfrag smarts-features
TOOLS = chisq-filter #pcprop
INSTALLDIR = /usr/local/bin

INCLUDE_OB  =  -I/usr/local/include/openbabel-2.0  
INCLUDE_GSL  =   
INCLUDE_R = -I/usr/share/R/include
LDFLAGS_OB  =  -L/usr/local/lib  
LDFLAGS_GSL  =   
LDFLAGS_R =


# Normally no edit needed below
OBJ = feature.o lazmol.o io.o rutils.o
HEADERS = lazmolvect.h feature.h lazmol.h io.h ServerSocket.h Socket.h feature-generation.h rutils.h
SERVER_OBJ = ServerSocket.o Socket.o
OBJ += $(SERVER_OBJ)

CC            = g++
INCLUDE       = $(INCLUDE_OB) $(INCLUDE_GSL) 
CXXFLAGS      = -g $(INCLUDE) -Wall -fPIC
LIBS	      = -lm -ldl -lopenbabel -lgslcblas -lgsl -lRblas -lRlapack -lR 
LDFLAGS       = $(LDFLAGS_OB) $(LDFLAGS_GSL)
SWIG          = swig

.PHONY:
all: $(PROGRAM)

.PHONY:
doc: Doxyfile
	doxygen Doxyfile

lazar: $(OBJ)  lazar.o 
	$(CC) $(CXXFLAGS) $(INCLUDE) $(LIBS) $(LDFLAGS) -o lazar $(OBJ)  lazar.o 

linfrag: $(OBJ) linfrag.o
	$(CC) $(CXXFLAGS) $(INCLUDE) $(LIBS) $(LDFLAGS) -o linfrag $(OBJ) linfrag.o

pcprop: $(OBJ) pcprop.o
	$(CC) $(CXXFLAGS) $(INCLUDE) $(LIBS) $(LDFLAGS) -o pcprop $(OBJ) pcprop.o

rex: $(OBJ) rex.o
	$(CC) $(CXXFLAGS) $(INCLUDE) $(LIBS) $(LDFLAGS) -o rex $(OBJ) rex.o

chisq-filter: $(OBJ)  chisq-filter.o 
	$(CC) $(CXXFLAGS) $(INCLUDE) $(LIBS) $(LDFLAGS) -o chisq-filter $(OBJ)  chisq-filter.o 

smarts-features: $(OBJ)  smarts-features.o 
	$(CC) $(CXXFLAGS) $(INCLUDE) $(LIBS) $(LDFLAGS) -o smarts-features $(OBJ)  smarts-features.o 

testset: $(OBJ)  testset.o 
	$(CC) $(CXXFLAGS) $(INCLUDE) $(LIBS) $(LDFLAGS) -o testset $(OBJ)  testset.o 

chisq-filter.o: $(HEADERS) activity-db.h feature-db.h 

rex.o: $(HEADERS) feature-generation.h

linfrag.o: $(HEADERS) feature-generation.h

pcprop.o: $(HEADERS)

smarts-features.o: $(HEADERS) feature-generation.h

lazar.o: $(HEADERS) predictor.h model.h activity-db.h feature-db.h feature-generation.h

lazmol.o: lazmol.h

feature.o: feature.h 

io.o: io.cpp io.h $(SERVER_OBJ)

rutils.o: rutils.h

testset.o: feature-generation.h

.PHONY:
clean:
	-rm -rf *.o $(PROGRAM) $(TOOLS) $(FEAT_GEN)
