#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2.8cm),
  numbering: "1",
  number-align: center,
)

#set text(font: "New Computer Modern", size: 10.5pt, lang: "en")
#set par(justify: true, leading: 0.65em)

#set heading(numbering: "1.1")
#show heading.where(level: 1): it => block(above: 1.4em, below: 0.7em)[
  #set text(size: 11pt, weight: "bold")
  #counter(heading).display("1.") #h(0.35em) #it.body
]
#show heading.where(level: 2): it => block(above: 1.1em, below: 0.5em)[
  #set text(size: 10.5pt, weight: "bold", style: "italic")
  #counter(heading).display("1.1") #h(0.35em) #it.body
]

#set math.equation(numbering: "(1)")

#set bibliography(style: "ieee")

#show link: it => text(fill: rgb("#1a56db"), weight: "bold")[#it]

#show figure.caption: it => text(size: 9pt, style: "italic")[#it]


#let title      = "Chimera States in Coupled Phase Oscillators"
#let authors    = (
  (name: "Darsh SA", credential: "MS22068"),
)
#let affiliation = "IDC-402: Nonlinear Dynamics Term Project"
#let abstract-text = [
  Chimera states are unusual spatiotemporal patterns in which an array of identical oscillators
  spontaneously splits into two coexisting domains: one coherent and phase-locked, the other
  incoherent and desynchronized. First found numerically by Kuramoto and Battogtokh
  @kuramoto2002 and analyzed exactly by Abrams and Strogatz @abrams2004, chimera states arise
  only under nonlocal coupling and cannot occur with purely local or purely global topologies.
  We simulate the Abrams–Strogatz model on a ring of $N = 512$ phase oscillators coupled
  through a cosine kernel $G(x) = (1 + A cos x) \/ (2 pi)$ with $A = 0.995$ and phase-lag
  $alpha = pi\/2 - 0.18$. We reproduce the key diagnostics from the original paper (the local
  coherence $R(x)$, local average phase $Theta(x)$, and mean drift frequency $Delta(x)$) and
  perform a bifurcation sweep over $alpha$ to find the critical threshold at
  $alpha approx 1.38$ where the system transitions from full synchronization
  ($chevron.l R chevron.r approx 1$) to a stable chimera ($chevron.l R chevron.r approx 0.6$).
  An automated chimera-survival mechanism ensures reliable nucleation from random initial
  conditions.
]
#let keywords = ("chimera states", "coupled oscillators", "nonlocal coupling", "phase dynamics", "spontaneous symmetry breaking", "Kuramoto model")


#align(center)[
  #block(below: 1.6em)[
    #text(size: 18pt, weight: "bold")[#title]
  ]

  #block(below: 0.7em)[
    #text(size: 11pt)[
      #authors.map(a => [#a.name (#a.credential)]).join([, ])
    ]
  ]

  #block(below: 2.4em)[
    #text(size: 10pt, style: "italic")[#affiliation]
    #footnote[Source code and report: #link("https://github.com/Darsh-A/Chimera_NLD")]
  ]
]

#align(center)[
  #box(width: 85%)[
    #align(left)[
      #text(weight: "bold")[Abstract: ]#abstract-text
    ]
  ]
]

#v(0.5em)
#align(center)[
  #box(width: 85%)[
    #align(left)[
      #text(weight: "bold", style: "italic")[Keywords: ]
      #keywords.join(", ")
    ]
  ]
]

#v(1.2em)
#line(length: 100%, stroke: 0.5pt)
#v(0.6em)


#columns(2, gutter: 2.0em)[

= Introduction

The study of coupled oscillators has a long history in nonlinear dynamics, starting with
Huygens' observation of sympathetic resonance between pendulum clocks in 1665 and later
formalized by Winfree @winfree1967 and Kuramoto @kuramoto1984. A fundamental question in
this field is what collective behaviors can emerge from a population of interacting
oscillators.

For _non-identical_ oscillators with distributed natural frequencies, partial synchronization
is well understood. Fast oscillators lock together while slow ones drift, and the boundary
between the two populations is set by the ratio of frequency spread to coupling strength
@kuramoto1984 @strogatz2015. The split is a direct result of heterogeneity among the
oscillators.

However, in 2002, Kuramoto and Battogtokh @kuramoto2002 discovered that a ring of
_identical_ oscillators could spontaneously break its own symmetry and split into coexisting
coherent and incoherent domains. The phenomenon (later named a "chimera state" by Abrams and
Strogatz @abrams2004) cannot be attributed to any difference between the oscillators. Every
oscillator follows the same equation with the same parameters, yet some lock together while
others drift, and the pattern persists indefinitely as a stable state.

Abrams and Strogatz @abrams2004 gave the first exact solution for chimera states, analyzing
a ring of phase oscillators coupled through a cosine kernel. They showed that the stable
chimera bifurcates from a spatially modulated drift state and is destroyed in a saddle-node
bifurcation with an unstable chimera, tracing out the precise region of parameter space where
chimeras can exist.

The key ingredient is *nonlocal coupling*, a topology intermediate between nearest-neighbor
(local) and all-to-all (global). Local coupling constrains spatial patterns through diffusive
smoothing. Global coupling gives every oscillator the same mean field, leaving no spatial
structure to break. Nonlocal coupling provides just enough spatial variation to sustain
coexisting coherent and incoherent domains @abrams2004 @shima2004.

Since then, chimera states have been observed in chemical oscillators @tinsley2012,
mechanical metronomes, and optical systems. They have also been connected to unihemispheric
sleep in certain animals, where one brain hemisphere stays awake while the other sleeps
@rattenborg2000.

*Scope of this project.* We simulate the Abrams–Strogatz model on a ring of $N = 512$
coupled phase oscillators, reproduce the key diagnostic plots from the original paper
@abrams2004, and sweep the phase-lag parameter $alpha$ to map the transition from full
synchronization to the chimera regime. All code and the compiled report are available at
#link("https://github.com/Darsh-A/Chimera_NLD").


= Mathematical Model

== Governing Equation

The simplest system known to support chimera states is a ring of phase oscillators governed
by the integro-differential equation @kuramoto2002 @abrams2004:

$
  (partial phi) / (partial t) = omega
    - integral_(-pi)^(pi) G(x - x') \
  quad quad quad quad quad
    times sin[phi(x, t) - phi(x', t) + alpha] thin d x'
$ <eq-gov>

Here $phi(x, t)$ is the phase of the oscillator at position $x$ on the ring at time $t$,
with $x in [-pi, pi]$ and periodic boundary conditions. The natural frequency $omega$ is the
same for all oscillators; one can set $phi arrow.r phi + omega t$ to eliminate it entirely,
so it plays no dynamical role. The parameter $alpha in [0, pi\/2]$ is a tunable phase lag
in the interaction function.

== Coupling Kernel

The kernel $G(x - x')$ controls how strongly oscillators at different positions interact.
Following Abrams and Strogatz @abrams2004, we use the cosine kernel:

$
  G(x) = (1 + A cos x) / (2 pi)
$ <eq-kernel>

where $0 <= A <= 1$. This kernel is even, non-negative, peaks at $x = 0$ (strongest coupling
between nearby oscillators), and integrates to one over the ring. When $A = 0$ the coupling
is all-to-all; when $A = 1$ neighboring oscillators are coupled twice as strongly as
diametrically opposite ones. The cosine form was chosen because it admits an exact analytical
solution of the self-consistency equations, unlike the exponential kernel originally used by
Kuramoto and Battogtokh @kuramoto2002.

== Complex Order Parameter

To measure local synchronization, Abrams and Strogatz introduce a space-dependent complex
order parameter @abrams2004:

$
  R(x, t) e^(i Theta(x, t))
    = integral_(-pi)^(pi) G(x - x') e^(i theta(x', t)) thin d x'
$ <eq-order>

where $theta = phi - Omega t$ is the phase measured in a frame rotating at frequency $Omega$.
The function $R(x)$ measures local coherence: $R(x) approx 1$ means oscillators near
position $x$ are well-synchronized, while $R(x) lt.double 1$ indicates incoherence. The function
$Theta(x)$ gives the local mean phase. In the steady chimera, both $R$ and $Theta$ depend on
space but not on time.

For the cosine kernel, the exact solution takes the form @abrams2004:

$
  R(x)^2 = |c|^2 + 2 thin "Re"(c a^*) cos x + |a|^2 cos^2 x
$ <eq-R>

$
  tan Theta(x) = (c_i + a_i cos x) / (c_r + a_r cos x)
$ <eq-Theta>

where $c$ and $a$ are coefficients determined self-consistently. This is why $R(x)$ comes
out with a cosine-like shape in the simulation.

== Discrete Approximation

For numerics, we place $N$ oscillators at equally spaced positions
$x_j = -pi + 2 pi j \/ N$ for $j = 0, 1, ..., N-1$. The integral in @eq-gov becomes a
Riemann sum with spacing $Delta x = 2 pi \/ N$:

$
  (d theta_i) / (d t) = omega
    - 1/N sum_(j=0)^(N-1) (1 + A cos(x_i - x_j)) \
  quad quad quad quad quad quad
    times sin(theta_i - theta_j + alpha)
$ <eq-discrete>

The $1\/(2 pi)$ in the kernel normalization cancels with $Delta x = 2 pi \/ N$, leaving
$1\/N$ as the overall prefactor. This is the system of $N$ coupled ODEs we integrate.

== Parameters

Following @abrams2004, we use $A = 0.995$ (strongly nonlocal coupling) and define
$beta = pi\/2 - alpha$, so $alpha = pi\/2 - beta$. The paper's Figure 1 uses $beta = 0.18$,
giving $alpha approx 1.391$. We use $N = 512$ oscillators (the paper uses $N = 256$;
the larger $N$ extends the chimera's metastable lifetime).


= Numerical Methods

== Initial Conditions

The initial phases are drawn from a Gaussian-bump perturbation centered at $x = 0$:

$
  phi_0(x) = a dot.op exp(-kappa x^2) dot.op r
$ <eq-ic>

where $r$ is uniform random on $[-1\/2, 1\/2]$, $a = 6$ is the amplitude, and $kappa$
controls the width. The original paper uses $kappa = 30$ (a narrow spike) with a fixed-step
RK4 integrator at $delta t = 0.025$. For our adaptive RK45 solver, we found that
$kappa = 0.76$ (a much wider bump) nucleates the chimera more reliably. The adaptive
solver's variable step size tends to smooth out very localized features during the first few
time steps, so the wider initial kick is needed to seed incoherence over a large enough
spatial extent.

== Time Integration

We integrate @eq-discrete using SciPy's `solve_ivp` with the Dormand–Prince RK45 method.
The key settings are listed in @tab-solver.

#figure(
  table(
    columns: (auto, auto),
    inset: 6pt,
    align: (left, left),
    table.header([*Parameter*], [*Value*]),
    [Method],        [RK45 (adaptive)],
    [Time span],     [$t in [0, 5000]$],
    [Output points], [1000],
    [Max step size], [0.1],
  ),
  caption: [Time-integration settings.],
) <tab-solver>

The maximum step of $0.1$ is much smaller than the default and close to the paper's fixed
$delta t = 0.025$. This ensures the fast phase dynamics during chimera formation are
adequately resolved while still benefiting from adaptive error control.

== Chimera Survival Check

Chimera states in finite-$N$ systems are metastable: they can collapse to full
synchronization after a random (but typically long) time. Not every initial condition
successfully nucleates a chimera either. We handle both issues with an automated retry
mechanism:

+ Generate a random initial condition from @eq-ic.
+ Run a short *probe simulation* to $t = 500$ (10% of the full run).
+ Compute the global order parameter $R = |1\/N sum_j e^(i theta_j)|$ at the probe endpoint.
+ If $R > 0.93$, the chimera has collapsed; discard and retry with a new random seed.
+ If $R < 0.93$, the chimera is alive; proceed with the full $t = 5000$ simulation.
+ Repeat up to 10 attempts.

This way the expensive full simulation only runs when the chimera has actually nucleated.

== Diagnostics

We compute the following quantities from the simulation output:

- *Sliding-window local order parameter* $|z(x)|$: For each oscillator $i$, we average
  $e^(i theta_j)$ over a window of $2w + 1 = 81$ neighbors (periodic boundary) and take the
  modulus. Values near 1 indicate local coherence; values $lt.double 1$ indicate incoherence.

- *Kernel-weighted order parameter* $R(x)$ and $Theta(x)$: Computed directly from
  @eq-order using the coupling kernel $G$. This matches the paper's definition exactly.

- *Mean drift frequency* $chevron.l dot(theta)_i chevron.r$: Time-averaged angular velocity
  of each oscillator, computed from the unwrapped phase difference over the second half of
  the simulation. Locked oscillators share a common frequency; drifting ones have a
  spatially varying frequency.

- *Global order parameter* $chevron.l R chevron.r$: Time-averaged value of
  $|1\/N sum_j e^(i theta_j)|$ over the steady-state portion, used for the bifurcation
  sweep.


= Results and Analysis

== Phase Evolution

@fig-snapshots shows snapshots of the oscillator phases at five key time-steps, capturing
the evolution of the chimera from nucleation to its steady state.

#figure(
  placement: top,
  scope: "parent",
  image("../plots/phase_snapshots.png", width: 100%),
  caption: [
    Phase snapshots at five key times. From left to right: Gaussian-bump initial condition
    ($t = 0$), early chimera nucleation ($t = 501$), developing chimera ($t = 2503$),
    mature chimera ($t = 4505$), and final steady state ($t = 5000$).
    Parameters: $N = 512$, $A = 0.995$, $alpha = 1.391$.
  ],
) <fig-snapshots>

At $t = 0$, the initial condition shows a spread of phases near $x = 0$, with all other
oscillators starting near $theta = 0$. By $t = 501$ the chimera has formed: oscillators
near $x approx plus.minus pi$ have locked onto a common phase (the smooth arc), while
those in the middle have started to drift apart. The middle panels ($t = 2503$,
$t = 4505$) show the mature chimera, with a clearly defined coherent arc coexisting with
a scattered cloud of drifting oscillators. The final panel confirms that by $t = 5000$
the state is statistically steady.

The locked oscillators slow down as they pass through the coherent pack, which is why the
scattered dots cluster more densely near the coherent arc, a feature also noted in
@abrams2004.

== Local Order Parameter

@fig-local shows the sliding-window local order parameter $|z(x)|$ at the final
time-step, giving a direct, model-independent measure of local synchronization at each
ring position.

#figure(
  image("../plots/local_order.png", width: 100%),
  caption: [
    Sliding-window local order parameter $|z(x)|$ at $t = 5000$.
    Window size: $2 times 40 + 1 = 81$ oscillators.
  ],
) <fig-local>

The plot shows the expected chimera structure:

- $|z(x)| approx 1.0$ near $x approx plus.minus pi$: oscillators are fully phase-locked.
- $|z(x)|$ drops to roughly $0.35$ in the incoherent region around $x approx -1$,
  indicating a nearly uniform phase distribution.

The jaggedness in the incoherent region is a finite-$N$ effect: with only 81 oscillators
in the averaging window, statistical fluctuations in the random phases produce small
variations in $|z|$. These would shrink with larger $N$ or wider windows.

== Reproduction of Paper Figure 1

@fig-paper reproduces the three-panel diagnostic from Figure 1 of @abrams2004, using the
kernel-weighted complex order parameter from @eq-order.

#figure(
  image("../plots/paper_fig1.png", width: 100%),
  caption: [
    Reproduction of Figure 1 from @abrams2004.
    (a) Phase snapshot $theta(x)$.
    (b) Local coherence $R(x)$.
    (c) Local average phase $Theta(x)$.
  ],
) <fig-paper>

*Panel (a)* shows the phase snapshot at $t = 5000$. Locked oscillators near
$x approx plus.minus pi$ lie on a smooth arc at $theta approx -2.5$; drifting oscillators
in the middle are scattered across all phases and cluster more densely near the arc
because they slow down as they pass through the coherent pack @abrams2004.

*Panel (b)* shows the kernel-weighted $R(x)$ from @eq-order. Unlike the sliding-window
$|z(x)|$ in @fig-local, this uses the coupling kernel $G(x)$ as the weighting function,
matching the paper's exact definition. The profile is smooth and cosine-like, ranging
from $R approx 0.78$ at the ring boundaries to $R approx 0.48$ in the incoherent center.
This shape is predicted by the exact solution @eq-R.

*Panel (c)* shows the local average phase $Theta(x)$, varying smoothly from
$Theta approx -2.3$ at the edges to $Theta approx -1.9$ at the center, consistent with
the cosine profile predicted by @eq-Theta.

== Mean Drift Frequency

@fig-drift shows the time-averaged angular velocity $chevron.l dot(theta) chevron.r$ of each
oscillator, computed from unwrapped phases over the second half of the simulation.

#figure(
  image("../plots/drift_frequency.png", width: 100%),
  caption: [Mean drift frequency $chevron.l dot(theta) chevron.r (x)$ for each oscillator.],
) <fig-drift>

The oscillators split into two distinct groups:

- *Locked oscillators* (near $x approx plus.minus pi$): All share the same time-averaged
  frequency $chevron.l dot(theta) chevron.r approx 0.52$, forming a flat plateau. This common
  frequency is the collective rotation rate of the coherent domain.

- *Drifting oscillators* (middle): Their time-averaged frequency drops smoothly to
  $chevron.l dot(theta) chevron.r approx -0.2$ near $x approx 0$, forming a bowl-shaped
  profile. The smooth variation within the drifting region reflects how much time each
  drifter spends near the locked pack depending on its position.

The transition between the locked plateau and the drifting bowl occurs at
$x approx plus.minus 2$, which matches the boundary where $R(x)$ falls below the critical
threshold in the paper's self-consistency analysis @abrams2004. Identical oscillators under
the same coupling end up with measurably different long-term frequencies depending solely on
their position on the ring.

== Bifurcation Analysis

@fig-bifurc shows the time-averaged global order parameter $chevron.l R chevron.r$ as a
function of $alpha$, from a sweep of 20 evenly spaced values in $[1.2, pi\/2]$.

#figure(
  image("../plots/bifurcation_sweep.png", width: 100%),
  caption: [
    Bifurcation sweep: global order parameter $chevron.l R chevron.r$ vs. phase-lag $alpha$.
  ],
) <fig-bifurc>

The sweep reveals three distinct regimes:

- *Full synchronization* ($alpha lt.tilde 1.37$): $chevron.l R chevron.r approx 1.0$, meaning
  all oscillators are phase-locked and the synchronized state is the only stable attractor.

- *Critical transition* ($alpha approx 1.38$): A sharp drop from $approx 1.0$ to
  $approx 0.63$ over a very narrow range of $alpha$. This is where the chimera state
  is born.

- *Chimera regime* ($alpha gt.tilde 1.39$): The order parameter sits around
  $chevron.l R chevron.r approx 0.57$–$0.63$, reflecting the stable mixture of locked and
  drifting oscillators. The intermediate value (neither 0 nor 1) is the chimera's
  fingerprint.

- *Approach to full drift* ($alpha arrow pi\/2$): $chevron.l R chevron.r$ gradually drops
  further toward $approx 0.50$ as the coupling becomes increasingly anti-phase.

The critical value $alpha_c approx 1.38$ corresponds to $beta_c = pi\/2 - alpha_c approx
0.19$, consistent with the chimera existence boundary predicted by @abrams2004 for
$A = 0.995$. In the paper, the chimera disappears via a saddle-node bifurcation at a
maximum $beta_max$ that depends on $A$. Our numerical sweep captures this transition
cleanly.


= Discussion

== Comparison with the Original Paper

Our results are in good qualitative agreement with the analytical predictions and
simulations of @abrams2004:

- The phase snapshot (@fig-paper, panel a) matches the paper's Figure 1a: locked
  oscillators near $x = plus.minus pi$, drifting oscillators in the middle.
- The kernel-weighted $R(x)$ profile (panel b) is smooth and cosine-like, as predicted
  by @eq-R, with minimum $R approx 0.48$.
- The $Theta(x)$ profile (panel c) shows the expected cosine variation from @eq-Theta.
- The drift frequency (@fig-drift) shows the characteristic flat-plateau-plus-bowl
  structure with a sharp boundary between locked and drifting populations.
- The bifurcation sweep (@fig-bifurc) places the sync-to-chimera transition at the
  expected $alpha$ value.

== Finite-$N$ Effects

Several features of our results come from the finite oscillator count:

- *Jagged $|z(x)|$*: The sliding-window order parameter (@fig-local) fluctuates in the
  incoherent region because the local average is over a finite window of 81 oscillators.
  The kernel-weighted $R(x)$ (@fig-paper, panel b) is smoother because it uses the full
  coupling kernel as the weight function.

- *Chimera metastability*: In the $N arrow infinity$ limit, chimera states are true
  attractors. For finite $N$ they are metastable: the chimera will eventually collapse,
  though the collapse time grows exponentially with $N$. The chimera-survival check
  (Section 3.3) deals with this by catching early collapses and retrying.

- *Sensitivity to initial conditions*: Not every random perturbation nucleates a chimera.
  The retry mechanism typically needs 1–3 attempts, which confirms that chimera nucleation
  is genuinely sensitive to the initial kick.

== Numerical Considerations

The original paper uses a fixed-step RK4 integrator at $delta t = 0.025$ and initial
condition width $kappa = 30$. Our adaptive RK45 solver required two adjustments:

1. *Wider initial perturbation* ($kappa = 0.76$ vs. $30$): The narrow Gaussian spike with
   $kappa = 30$ was routinely absorbed into the synchronized state before the chimera could
   form. The adaptive solver's variable step size smooths out very localized features in
   the early transient, so a wider initial kick is needed to seed incoherence over a large
   enough spatial extent.

2. *Capped maximum step* (max\_step $= 0.1$): Without this, the solver occasionally took
   steps large enough to skip over the fast phase dynamics during chimera formation.
   The cap of $0.1$ keeps temporal resolution adequate while still benefiting from
   adaptive error control.


= Conclusion

In summary, we successfully simulated chimera states in the Abrams–Strogatz model, showing
that a ring of 512 identical oscillators can spontaneously split into a coherent
(phase-locked) domain and an incoherent (drifting) domain with no heterogeneity required.
Our quantitative diagnostics (local coherence $R(x)$, local average phase $Theta(x)$, and
mean drift frequency $chevron.l dot(theta) chevron.r (x)$) closely match the exact analytical
predictions of @abrams2004, and the reproduced three-panel figure agrees well with the
original paper's Figure 1.

Additionally, our bifurcation sweep over $alpha$ located the critical transition at
$alpha_c approx 1.38$, where $chevron.l R chevron.r$ drops sharply from $approx 1$ to
$approx 0.6$, consistent with the saddle-node bifurcation predicted by @abrams2004.
Dealing with finite-size effects also showed that while the chimera is stable once formed,
its nucleation is highly sensitive to initial conditions, requiring an automated retry
mechanism and careful tuning of the solver. Ultimately, replicating this model demonstrates
how nonlocal coupling provides the spatial degrees of freedom necessary for coherent and
incoherent domains to coexist. Future work could explore how these states behave under
different coupling topologies or in two-dimensional arrays.


]

#bibliography("references.bib")
