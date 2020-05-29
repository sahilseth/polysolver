arguments <- commandArgs(trailingOnly = TRUE)

PCA_tsv=arguments[1]
training_race_annotations=arguments[2]
project_samples=arguments[3]
project_name=arguments[4]
outdir=arguments[5]


PCA=read.delim(PCA_tsv, sep="\t", header=FALSE)
Evectors=paste("Comp", 1:100, sep="")
names(PCA)=c("Sample_ID", Evectors, "Control")

#Annotate PCA Table with ESP/1000G Population Tags
annotations=read.delim(training_race_annotations, header=TRUE)

PCA=merge(PCA, annotations, by="Sample_ID", all.x=TRUE)

project=read.delim(project_samples, header=TRUE)

#Train on everything except the project dataset
remove=match(project$Sample_ID, PCA$Sample_ID)
if (length(which(is.na(remove)))>0) {remove=remove[-which(is.na(remove))]}
Training=PCA[-remove,]
Evaluate=PCA[remove,]

#Remove all Hispanics
hisp=which(Training$Race=="Hispanic")
Training=Training[-hisp,]

maxPC=2
Training.Means=aggregate(Training[,2:(maxPC+1)], by=list(Training$Race), mean) #Estimate the means for each component for each racial group
Evaluate=Evaluate[,1:(maxPC+1)] #Trim the Evaluating table to relevant columns only
Eval.Merge=merge(Evaluate, Training.Means, all=T, by=NULL)
Eval.Merge$Distance=apply(Eval.Merge, 1, FUN=function(row) { sqrt(sum((as.numeric(row[2:(maxPC+1)])-as.numeric(row[(maxPC+3):(maxPC+maxPC+2)]))^2)) }) #Calculate the distance of each sample from the estimated PCA centers for each race
Eval.Merge.Distance=Eval.Merge[,c("Sample_ID", "Group.1", "Distance")]
colnames(Eval.Merge.Distance)=c("Sample_ID", "Group", "Distance")
library(reshape)
Distances=cast(Eval.Merge.Distance, Sample_ID ~ Group, value="Distance")
RefGroupCount=length(unique(Training$Race))
Distances$ClosestPopulation=colnames(Distances)[1+apply(Distances[,2:(RefGroupCount+1)], 1, FUN=which.min)]
Distances$NextClosestPop=colnames(Distances)[1+apply(Distances[,2:(RefGroupCount+1)], 1, FUN=function(row) {which(row %in% sort(row)[2])})]
Distances$Ratio=1/(apply(Distances[,2:(RefGroupCount+1)], 1, FUN=min)/apply(Distances[,2:(RefGroupCount+1)], 1, FUN=function(row) {sort(row)[2]}))
Comp.Merged=merge(Distances, Evaluate, by="Sample_ID", all.x=TRUE)


Inference=Comp.Merged[,c("Sample_ID", "ClosestPopulation", "NextClosestPop", "Ratio")]
write.table(Inference, paste(outdir, "/", project_name, "_Inference_Results.txt", sep=""), col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")

library(ggplot2)

pl <- ggplot(Training, aes(x = Comp1, y = Comp2, color=Race)) + geom_point() + ylab("PC2") + xlab("PC1") + scale_color_discrete(name="Ethnicity of\nTraining Set")
pl + geom_point(data=Comp.Merged, aes(x = Comp1, y = Comp2, shape=ClosestPopulation), color="black") + scale_shape_discrete(name="Inferred Ethnicity of\nValidation Set")
ggsave(paste(outdir, "/", project_name, "_Inference_Plot.pdf", sep=""))
