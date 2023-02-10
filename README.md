# GETVocoder

Introduction:

This MATLAB code implements a Gaussian-enveloped tone (GET) vocoder. The concept and theory behind the GET vocoder is thoroughly explained in [1].

In addition, a Gaussian-enveloped noise (GEN) vocoder can be created by altering the carrier of the GET vocoder from a tone to noise. The idea of the GEN vocoder can be found in [2]. A comprehensive experiment on the GEN vocoder is presented in [2].

References:

[1] Qinglin Meng, Huali Zhou, Thomas Lu, and Fan-Gang Zeng. "Pulsatile Gaussian-Enveloped Tones (GET) Vocoders for Cochlear-Implant Simulation." Submitted to a Journal, December 2022.

[2] Fanhui Kong, Huali Zhou, Yefei Mo, Mingyue Shi, Qinglin Meng, Nenghengzheng. "Comparable Encoding, Comparable Perceptual Pattern: Acoustic and Electric Hearing." Submitted to a Journal, February 2023.

Size: Approximately 700 KB

Platform: This code requires MATLAB R2020a or a newer version.

Requirements: No additional environment requirements.

Usage: The main code for the GET vocoder is GETvoc.m. To use the code, simply run VocMain.m. This will produce a figure and present a vocoded sound.

Note: The code for the ACE strategy and spectrogram are sourced from third-party sources. The ACE strategy program has been adapted from the CCiMobile program, which can be found at https://github.com/CILabUTD/CCi-MOBILE.

Contact:

For any questions or concerns, please contact Qinglin Meng at the Acoustics Lab of the School of Physics and Optoelectronics at South China University of Technology. Email addresses: mengqinglin@scut.edu.cn or mengqinglin08@gmail.com.
