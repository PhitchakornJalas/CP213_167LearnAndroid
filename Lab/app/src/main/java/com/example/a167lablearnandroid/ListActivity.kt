package com.example.a167lablearnandroid

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Divider
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.example.a167lablearnandroid.ui.theme._167LabLearnAndroidTheme

class ListActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        enableEdgeToEdge()
        Log.i("Lifecycle", "ListActivity : onCreate")
        setContent {
            listScreen(PokemonViewModel())
        }
    }

    override fun onStart() {
        super.onStart()
        Log.i("Lifecycle", "ListActivity : onStart")
    }

    override fun onResume() {
        super.onResume()
        Log.i("Lifecycle", "ListActivity : onResume")
    }

    override fun onPause() {
        super.onPause()
        Log.i("Lifecycle", "ListActivity : onPause")
    }

    override fun onStop() {
        super.onStop()
        Log.i("Lifecycle", "ListActivity : onStop")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.i("Lifecycle", "ListActivity : onDestroy")
    }

    override fun onRestart() {
        super.onRestart()
        Log.i("Lifecycle", "ListActivity : onRestart")
    }
}

@Composable
fun listScreen(viewModel: PokemonViewModel) {

    val pokemonList by viewModel.pokemonList.collectAsState()

    Column( // dark gray border
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF2B2C30))
            .padding(16.dp)
    ) {
        Row( // red blood pig
            modifier = Modifier
                .fillMaxWidth()
                .height(100.dp)
                .background(Color(0xFF7F170F))
        ) {
            Row( // header tab
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier
                    .padding(16.dp)
            ) {
                Box( // circle top left
                    modifier = Modifier
                        .size(70.dp)
                        .background(Color(0xFFE2E1E6), shape = CircleShape)
                ) {
                    Box(
                        modifier = Modifier
                            .size(60.dp)
                            .background(Color(0xFF314396), shape = CircleShape)
                            .align(Alignment.Center)
                            .padding(10.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(20.dp)
                                .background(Color(0xFFC8CBE3), shape = CircleShape)
                                .align(Alignment.TopStart)

                        ) { }
                    }
                }

                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(start = 16.dp, end = 8.dp)
                ) {
                    Row(
                        modifier = Modifier
                            .width(60.dp)
                            .padding(bottom = 8.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Box(
                            modifier = Modifier
                                .size(16.dp)
                                .background(Color(0xFFEA3323), shape = CircleShape)
                                .border(1.dp, Color.White, CircleShape)
                        ) { }
                        Box(
                            modifier = Modifier
                                .size(16.dp)
                                .background(Color(0xFFFFFE54), shape = CircleShape)
                                .border(1.dp, Color.White, CircleShape)
                        ) { }
                        Box(
                            modifier = Modifier
                                .size(16.dp)
                                .background(Color(0xFF75FB4C), shape = CircleShape)
                                .border(1.dp, Color.White, CircleShape)
                        ) { }
                    }

                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(35.dp)
                            .background(Color(0xFFB0281E), shape = CircleShape)
                    ) { 

                    }
                }
            }
        }

        Row( // red
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFFB2281E))
                .padding(16.dp)
        ) {
            Column( // round gray border
                modifier = Modifier
                    .fillMaxSize()
                    .background(Color(0XFFAFB0B3),  shape = RoundedCornerShape(32.dp))
                    .padding(5.dp)
            ) {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color.White, shape = RoundedCornerShape(34.dp))
                        .border(2.dp, Color.Black, RoundedCornerShape(34.dp))
                        .padding(16.dp)
                ) {
                    items(pokemonList) { item ->
                        Row(
                            modifier = Modifier
                                .fillMaxSize()
                                .padding(16.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(text = "#${item.entry_number.toString()} ${item.pokemon_species.name}",
                                fontSize = 20.sp,
                                color = Color(0xFF656565))

                            val imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${item.entry_number}.png"
                            AsyncImage(
                                model = imageUrl,
                                contentDescription = "Sprite of ${item.pokemon_species.name}",
                                modifier = Modifier
                                    .size(32.dp),
                                placeholder = painterResource(id = R.drawable.ic_launcher_foreground),
                                error = painterResource(id = R.drawable.ic_launcher_background)
                            )
                        }
                        Divider()
                    }
                }
            }
        }

    }

}

@Preview
@Composable
fun listPreview() {
    listScreen(PokemonViewModel())
}