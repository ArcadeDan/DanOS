
void dummy_test_entrypoint() 
{

}


void kernel_main(void)
{
    while (1)
    {
    char* video_memory = (char*) 0xb8000;
    *video_memory = 'X';
    }
}
