# Computation of Error Distribution in Rayleigh Fading Channel

Assume the channel is a frequency-nonselective fast-fading channel with Rayleigh distribution fading channel coefficient. and the system adopt BPSK modulation.

The transmission process can be expressed as
$$
y_b(n) = h(n)x(n) + w(n)
$$
where
$$
h \sim \mathcal{CN}(0,2\sigma_h^2) \quad\quad w \sim \mathcal{CN}(0,2\sigma_w^2) \\ \\
x = \pm m
$$
To simplify the system, let $2\sigma_h^2 = 1$.

The complex Gaussian distributed channel coefficient and additive white noise can also be written as
$$
h = h_R + jh_I = ae^{j\alpha} \\ \\
w = w_R + jw_I = be^{j\beta}
$$
where $a,b$ is Rayleigh distributed and $\alpha, \beta$ is uniformly distributed between $0$ and $2\pi$.

To eliminate the effect of fading channel, received signal will divide by channel coefficient $h$.
$$
y_{rx} = \real \Bigg[ x + \frac{b e^{j(\beta - \alpha)}}{a} \Bigg]
$$
It can be verified that $e^{j(\beta-\alpha)}$ is distributed same as $e^{j\beta}$, so $be^{j(\beta-\alpha)}$ also obeys complex Gaussian distribution, i.e.
$$
be^{j\beta-\alpha} = be^{j\psi} \sim \mathcal{CN}(0,2\sigma_w^2)
$$
What we are interested in is its real part $c \sim \mathcal{N}(0,\sigma_w^2)$. The received sequence is expressed as
$$
y_{rx} = \real \bigg[ x + \frac{c}{a} \bigg]
$$
The PDF of $a,c$ is
$$
f_C(c) = \frac{1}{\sqrt{2\pi}\sigma_w}e^{-\frac{c^2}{2\sigma_w^2}} \\ \\
f_A(a) = \frac{a}{2\sigma_h^2}e^{-\frac{a^2}{4\sigma_h^2}} = ae^{-\frac{a^2}{2}}
$$
$a,c$ is independent, so the joint PDF of $a,c$ is
$$
f_{A,C}(a,c) = f_C(c) f_A(a) = \frac{a}{\sqrt{2\pi}\sigma_w}e^{-(\frac{c^2}{2\sigma_w^2} + \frac{a^2}{2})}
$$
Let $\frac{c}{a} = r$, replace $c$ with $ar$:
$$
f_{A,R}(a,ra) = \frac{a}{\sqrt{2\pi}\sigma_w}e^{-(\frac{r^2a^2}{2\sigma_w^2} + \frac{a^2}{2})} = \frac{a}{\sqrt{2\pi}\sigma_w}e^{-a^2(\frac{r^2}{2\sigma_w^2} + \frac{1}{2})}
$$
Let $\frac{r^2}{2\sigma_w^2} + \frac{1}{2} = p$ and $\sqrt{2\pi}\sigma_w = q$, the PDF of $r$ can be verified as
$$
\begin{align}
f_R(r) &= \int_{0}^{\infin}f_{A,R}(a,ra)\ \mathrm{d}a\ = \int_{0}^{\infin} \frac{a}{q}e^{-a^2p}\ \mathrm{d}a \\ \\
&= \Bigg[ -\frac{1}{2pq}e^{-a^2p} \Bigg]_0^{\infin} \\ \\
&= \frac{1}{2pq} \\ \\
&= \frac{\sigma_w}{\sqrt{2\pi}(r^2+\sigma_w^2)}
\end{align}
$$
Apparently, variable $r$ is not Gaussian or Rayleigh distributed.
