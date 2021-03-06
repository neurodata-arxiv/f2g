Instructions (from the EC2 instance except where noted)

echo "dataset=\"datasetname\"; export dataset" >> .bashrc  
echo "ctxpath=\"/mnt/ssd1/public/Data/\"; export ctxpath" >> .bashrc  
. ~/.bashrc  

sudo apt-get install s3cmd  
scp eric@braincloud1.cs.jhu.edu:/home/eric/.s3cfg /home/ubuntu/  
1) clone the f2g repo in ~/  
git clone https://github.com/neurodata/f2g.git  

2) run the setup script.  
. ~/f2g/setup_ami_cpac.sh  

- HCP substep: get the subjects  
scp eric@braincloud1.cs.jhu.edu:/home/eric/hcpaa /home/ubuntu/f2g/CPAC_sublists/
			
- substep: make sure you have the subjects in the inputs directory -  
scp -r eric@cortex.cs.jhu.edu:/mnt/ssd1/public/Data/$dataset/inputs/ /home/ubuntu/Documents/  

3) find the sesssions, and place in appropriate directory."  
find /home/ubuntu/Documents/inputs/ -maxdepth 2 -name "\*session\*" -type d >   /home/ubuntu/f2g/CPAC_sublists/dataset_sublists.txt  
  
4) make the subject lists for cpac.  
-step btwn-  
cd /home/ubuntu/f2g/CPAC_sublists  
  
./make_sublist.sh dataset_sublists.txt  

./get_hcp.sh hcpaa
  
-test and make sure things are there-  
cat dataset_sublists.yml  
			  
-step-  
cd ../CPAC_cli	  
  	
4) run the subjects.  

nohup python CPAC_cli.py -s ../CPAC_sublists/hcp_sublist.yml -c ../CPAC_pipes/best_pipeline.yml -n fsl > log.txt &

nohup python CPAC_cli.py -s ../CPAC_sublists/dataset_sublists.yml -c ../CPAC_pipes/pipeline_config_abide_run.yml -n name &  

- to delete not useful files midway -  
find /home/ubuntu/Documents/output/* ! -name "*.npz" -exec rm '{}' ';'  

5) move to the moving outputs directory.  
find /home/ubuntu/Documents/output/pipeline_abide_run__* -name "*.npz" > npzpaths.txt  
  
6) move the files to the outputs directory  
./rename_byline.sh npzpaths.txt /home/ubuntu/Documents/outputs/  
  
7) Copy folder to ctx for rest of processing... making sure to make the directory you are placing first	  
-on cortex...-  
mkdir /mnt/ssd1/public/Data/$dataset/derivatives  
mkdir /mnt/ssd1/public/Data/$dataset/derivatives/timeseries  

-on AMI-  
scp -r /home/ubuntu/Documents/outputs/* eric@cortex.cs.jhu.edu:/mnt/ssd1/public/Data/$dataset/derivatives/timeseries  
  
6) Copy to a new file  
cp npzpaths.txt graphmlpaths.txt  

7) rename the graphml paths  		
sed -i 's/npz/graphml/g' graphmlpaths.txt  
  
9) convert the npz files to graphml with the shell script that calls npz2graphml  
./convert_byline.sh npzpaths.txt graphmlpaths.txt  
  
10) run analysis on the subjects, making sure that process_fmri.R and reliability.R are in the current folder  
Rscript process_fmri.R datasetname  
  
