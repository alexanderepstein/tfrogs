<div align="center">

# Time Frequency Regularized Overlapping Group Shrinkage (TFROGS)

<img src="https://img.freepik.com/free-vector/cute-frog-green-tea-cartoon-vector-icon-illustration-animal-drink-icon-concept-isolated-premium-vector-flat-cartoon-style_138676-3694.jpg?w=740&t=st=1667741307~exp=1667741907~hmac=c8b627abd413e144bda3b6014b0680070905ac26230c274a6c88d7d97587ecbe" height="250px" width="250px">

###### Image by catalyststuff on Freepik

### Optimization approach for audio denoising
##### Alex Epstein, Nimish Magre, Jared Miller

</div>

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
Coming soon...