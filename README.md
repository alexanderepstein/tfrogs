<div align="center">

# Time Frequency Regularized Overlapping Group Shrinkage (TFROGS)

<img src="https://img.freepik.com/free-vector/cute-frog-green-tea-cartoon-vector-icon-illustration-animal-drink-icon-concept-isolated-premium-vector-flat-cartoon-style_138676-3694.jpg?w=740&t=st=1667741307~exp=1667741907~hmac=c8b627abd413e144bda3b6014b0680070905ac26230c274a6c88d7d97587ecbe" height="250px" width="250px">

###### Image by catalyststuff on Freepik

### Optimization approach for audio denoising
##### Alex Epstein, Nimish Magre, Jared Miller

</div>

## Abstract
In this work, we denoise speech samples using predetermined structural knowledge of decomposable convex optimization problems. To this end, we exploit the grouping/clustering property observed with speech spectrograms to iteratively obtain a sparse clean speech signal using a mixed norm penalty term. We build upon the Overlapping Group Shrinkage (OGS) algorithm and introduce time-frequency weights to the cost function to rid the sparse clean signal of the residual noise. These time-frequency weighting extensions are also empirically shown to effectively handle impulsive noise types. The time-frequency weights may be targeted to suppress specific noise types at desired time slices to further improve the performance of the algorithm.

## Running the code
### Downloading
If you are familar with git then we can clone the repository

```bash
git clone https://github.com/alexanderepstein/tfrogs
```

Otherwise on github we can look to the top right of the TFROGS repository and click the `code` dropdown. From this dropdown we can select `Download Zip` which should download a compressed version of the repository that you can then decompress on your local machine.

### Running sample
The code is setup to run a provided sample of both speech & noise. 
Open the file `code/test_tfrogs.m` in Matlab and run it.

### Using your own speech & noise
In `code/test_tfrogs.m` replace the two `audioread` lines towards the top of the file with paths to your audio data. Then run `code/test_tfrogs.m` again. You can also specify the SNR for the combined noisy signal by setting the `SNR` parameter. It may be neccessary to modify the parameters including: `noise_type, lambda, Nit, K1 & K2` to get the best performance possible. 

### Using AWGN as noise source 
To use additive white gaussian noise as the noise source uncomment the line in `code/test_tfrogs.m` that includes the command `awgn`. This will also abide by the previously set `SNR` parameter. 

### Modifying time weighting
Time weighting uses the energy ratios of the signal, there are other ways to weight time that we can think of. For example a single alternative is provided in `code/tfrogs.m` where we use the inverse of the typical ratio used for time weighting. You can also implement your own variations here.

### Modfying frequency weighting
In `code/test_tfrogs.m` there is a section for creating the frequency weights. Feel free to update the filter design there to suit your needs. This may be useful for trying to extract a different target signal other than speech from your noisy signal.

## Experiments & Results

Experiments were run using clean speech files from [LibriSpeech](https://www.openslr.org/12) and sampling 100 different clean speech files randomly from the set. For the noise data 5 different noise files were taken from  [MS-SNSD](https://github.com/microsoft/MS-SNSD). Each speech file is added with all the different noise files at -10 dB SNR and then is run through both OGS & TFROGS. For each algorithm we ran several values of lambda for each speech and noise combination and used the best result from each algorithm and lambda respectively. OGS used lambda values starting from 0.25 up to 5 in increments of 0.25. TFROGS used the same vector for lambda values, but scaled by 10. After the experiments completed we then took the mean SNR value for each noise file across all of the speech files as well as the variance. The data from the experiment is in the table below. 

| Noise File/Algorithm | OGS SNR (db)  | TFROGS SNR (db) | Noise Type      |
| -------------------- | ------------- | --------------- | --------------- |
| Copy Machine         | -0.03 ± 0.18  | -0.61 ± 0.61    | Semi-Stationary |
| Keyboard Clicks      | -0.43 ± 0.50  | 3.69 ± 0.71     | Impulsive       |
| Munching             | -0.06 ± 0.19  | 2.31 ± 0.95     | Impulsive       |
| Neighbor Noise       | -1.29 ± 1.07  | -5.50 ± 1.84    | Semi-Stationary |
| Vacuum               | -0.34 ± 0.57  | -0.03 ± 0.27    | Stationary      |