# Simple Channel Modeling

## 1	Introduction

The project models a simple wireless transmission channel and build up a whole digital communication system.

## 2	Fading Channel Model

### 2.1	General Description

The fading channel model is a combination of large-scale fading model and small-scale fading model. For large-scale fading, we adopt Okumura-Hata model and; For small-scale fading, we adopt Rayleigh fading channel model.

### 2.2	Okumura-Hata Model

Okumura-Hata model is adopted as the large-scale fading (path loss) model. It can be simply described by a formula
$$
PL = A + B\ log_{10}(d) + C \tag{2.2.1}
$$
where parameter A, B, C depends on various factors like $f_c,h_{BS},h_{MS},d$. Also, parameters vary at different application environment.

Function "HataPathLoss" is defined in the file "HataPathLoss.m".

File "HataModelCharacter.m" is used to test the model.

The path loss and path gain changes with the distance between base station and mobile as is described in the figure below.

<center>
    <img style="border-radius: 0.3125em;
                box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"
         src=".\0_image_in_readme\hata_mod_test.svg">
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
                display: inline-block;
                color: #999;
                padding: 2px;">Figure 2.2.1  Okumura-Hata Model Characteristic</</div>
</center>

### 2.3	Rayleigh Fading Channel Model

#### 2.3.1	General Description

The channel model can be described by the following graph

<center>
    <img style="border-radius: 0.3125em;
                box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"
         src=".\0_image_in_readme\time_vary_channel_struct_iq.svg">
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
                display: inline-block;
                color: #999;
                padding: 2px;">Figure 2.3.1  Channel Model Frame</</div>
</center>

To simulate the channel in MATLAB, the model should be discretized and the channel impulse response $h_l(n)$ should cover the analog part including interpolation and  up-conversion. Thus, the fading channel coefficient can be written as
$$
h_l(n) = \sum\limits_i a_i(\frac{n}{F_s})\ e^{-j 2\pi f_c \tau_i(\frac{n}{F_s})}\ \mathrm{sinc}(l-\tau_i(\frac{n}{F_s})F_s) \tag{2.3.1}
$$

The derivation of the formula can be found in the document "Explanation for Transmission Formulas" Chapter 1 ~ 4.

Moreover, to simplify the modeling process, we temporarily consider the channel as a frequency nonselective one. In "Explanation for Transmission Formulas" Chapter 6, we have obtain the simplified baseband oriented channel model.

<center>
    <img style="border-radius: 0.3125em;
                box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"
         src=".\0_image_in_readme\freq_nonsel_chan.svg">
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
                display: inline-block;
                color: #999;
                padding: 2px;">Figure 2.3.2  Simplified Transmission Model for Flat Fading Channel</</div>
</center>

Function "RayleighFadingChannel" is defined in the file "RayleighFadingChannel.m".

File "RayleighChannCharacter.m" is used to test the model.

#### 2.3.2	Clarke Model and Jakes Method

The modeling process is a primary work for the tasks coming. So, we simply adopt Clarke Model here. Assume multipath wave at receiver evenly come from all direction.

The Rayleigh Fading Channel can then be modeled by Jakes Model in this project, where channel response is a complex Gaussian process and Gaussian distribution in both I and Q components are generated by sum of sinusoids.

<center>
    <img style="border-radius: 0.3125em;
                box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"
         src=".\0_image_in_readme\jakes_mod_implem.png">
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
                display: inline-block;
                color: #999;
                padding: 2px;">Figure 2.3.3  Implemention of Jakes Method</</div>
</center>

The formula can be expressed as
$$
\begin{align}
h_I(n) = 2\sum\limits_{n=1}^{N_0}(\mathrm{cos}\phi_n \mathrm{cos}\omega_n\frac{n}{F_s}) + \sqrt{2}\ \mathrm{cos}\phi_N \mathrm{cos}\omega_d\frac{n}{F_s} \\ \\
h_Q(n) = 2\sum\limits_{n=1}^{N_0}(\mathrm{sin}\phi_n \mathrm{cos}\omega_n\frac{n}{F_s}) + \sqrt{2}\ \mathrm{sin}\phi_N \mathrm{cos}\omega_d\frac{n}{F_s} \\ \\
\end{align} \tag{2.3.2}
$$
where $N_0$ represents the equivalent received rays at receiver, $\phi_n$ represents the initial phase of each received ray, $\omega_n$ represents the angular frequency of each received ray, $\omega_d$ represents the angular frequency of the ray that has the maximum doppler shift and $\phi_N$ represents its initial phase. Some of the parameters can be calculated as follow.
$$
\begin{align}
N_0 &= \frac{(N/2-1)}{2} \tag{2.3.3}\\ \\ 
\phi_n &= \frac{n\pi}{N_0+1}\quad n=1,2,\dots,N_0  \tag{2.3.4} \\ \\
\omega_n &= \omega_d \mathrm{cos}(2\pi n/N),\quad n=1,2,\dots,N_0 \tag{2.3.5} \\ \\
\phi_N &= 0 \tag{2.3.6} \\ \\
\omega_n &= 2\pi f_m \tag{2.3.7} \\ \\
f_m &= \frac{v}{f_c} = \frac{\lambda_c v}{c} \tag{2.3.8}
\end{align}
$$
where $N$ represents the total number of received rays at receiver, $f_m$ represents the maximum doppler shift, $f_c$ represents carrier wave frequency, $v$ represents the speed of mobile.

Thus, the complex channel impulse response can be written as
$$
h(n) = \frac{E}{\sqrt{2N_0+1}}\big[h_I(n)+jh_Q(n)\big] \tag{2.3.9}
$$
The program based on Jakes Method is tested by the test file and the result is shown below.

The fading channel coefficient's amplitude and angle changes with time as figure 2.3.4 displays.

<center>
    <img style="border-radius: 0.3125em;
                box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"
         src=".\0_image_in_readme\rayleigh_response.svg">
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
                display: inline-block;
                color: #999;
                padding: 2px;">Figure 2.3.4  Changing Fading Channel Coefficient</</div>
</center>

The coefficients amplitude and angle distribution are consistent with theoretical ones as is shown in figure 2.3.5.

<center>
    <img style="border-radius: 0.3125em;
                box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"
         src=".\0_image_in_readme\rayleigh_chann_distri.svg">
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
                display: inline-block;
                color: #999;
                padding: 2px;">Figure 2.3.5  Fading Channel Coefficient's Distribution</</div>
</center>

The autocorrelation function and power spectrum also meet with theoretical ones, conforming to doppler's theory as is shown in figure 2.3.6.

<center>
    <img style="border-radius: 0.3125em;
                box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);"
         src=".\0_image_in_readme\autocorr_spec.svg">
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
                display: inline-block;
                color: #999;
                padding: 2px;">Figure 2.3.6  Doppler Characteristics of Fading Channel Vector</</div>
</center>

## 3	Test the Model with Sinusoid

First we add a series of sine wave to the channel model. The test file is named "ChannelModelTestSinu.m"
