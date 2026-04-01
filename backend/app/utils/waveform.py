import random


def generate_waveform_data(num_points: int = 100, seed: int | None = None) -> list[float]:
    """Generate fake waveform data for demo purposes.

    Returns a list of float values between 0.0 and 1.0 that roughly
    resembles an audio waveform (smooth-ish, with peaks and valleys).

    Later this can be replaced with real audio analysis (e.g. using pydub/librosa).
    """
    rng = random.Random(seed)

    data: list[float] = []
    value = 0.5
    for _ in range(num_points):
        # Random walk with mean reversion toward 0.5
        delta = rng.gauss(0, 0.15)
        value += delta
        value = 0.7 * value + 0.3 * 0.5  # mean reversion
        value = max(0.05, min(0.95, value))  # clamp
        data.append(round(value, 3))

    return data
