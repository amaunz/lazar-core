require 'lazar'

p = Lazar::ClassificationPredictor.new("../cpdbdata/salmonella_mutagenicity/salmonella_mutagenicity_alt.smi", "../cpdbdata/salmonella_mutagenicity/salmonella_mutagenicity_alt.class", "../cpdbdata/salmonella_mutagenicity/salmonella_mutagenicity_alt.gsp.f6.l2.094705-090109.linfrag", "data/elements.txt", Lazar::getConsoleOut)

p.predict_smi("CC=NN(C)C=OC")
