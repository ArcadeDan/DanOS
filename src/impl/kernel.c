void dummy_test_entrypoint() 
{

}


void main()
{

    volatile char* video_memory = (char*) 0xb8000;
    video_memory[0] = 'X';
}