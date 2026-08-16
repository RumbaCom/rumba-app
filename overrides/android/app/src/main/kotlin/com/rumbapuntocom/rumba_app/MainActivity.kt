package com.rumbapuntocom.rumba_app

import com.ryanheise.audioservice.AudioServiceActivity

// Debe heredar de AudioServiceActivity para que la reproduccion
// en segundo plano y los controles del carro funcionen.
class MainActivity : AudioServiceActivity()
