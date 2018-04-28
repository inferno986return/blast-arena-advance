class FRAG {
   public:
                   FRAG(void)              ;
                  ~FRAG(void)              ;
      static  FRAG* NewHeader(void)        ;
             void  IsNowAfter(FRAG*)       ;
             void  IsNowBefore(FRAG*)      ;
             void  IsNowAfterSafe(FRAG*)   ;
             void  IsNowBeforeSafe(FRAG*)  ;
             void  Detach(void)            ;
      static void  ClearList(void)         ;

      static char  number                  ;
      static  FRAG* top;                   ;

              FRAG* Next                   ;
              FRAG* Previous               ;
             bool  header                  ;
              int  colour                  ;

              int  x                       ;
              int  y                       ;
};

char FRAG::number = 0;

FRAG* FRAG::top = FRAG::NewHeader();

FRAG* FRAG::NewHeader(void) {
   FRAG* a = new FRAG();
   a->header = true;
   FRAG::number = 0;
   return a;
}

FRAG::FRAG(void) {
   Previous = this;
   Next     = this;
   header   = false;
   FRAG::number++;
   //printf("I made FRAG! FRAG is %d!\n", data);
};

FRAG::~FRAG(void) {
   Detach();
};

void FRAG::IsNowAfter(FRAG* p) {
   Next           = p->Next;                        // Set the next of this FRAG to be the next of the FRAG to we're replacing.
   Previous       = p;                              // Set the prev of this FRAG to be the prev of the next FRAG.
   p->Next        = this;                           // This FRAG is after the FRAG before it, inform other FRAGs!
   Next->Previous = this;                           // This FRAG is before the one after it, inform other FRAGs!
   //printf("I attached FRAG %d to %d!\n", data, Previous->data);
};

void FRAG::IsNowAfterSafe(FRAG* p) {
   Next           = p->Next;                        // Set the next of this FRAG to be the next of the FRAG to we're replacing.
   Previous       = Next->Previous;                 // Set the prev of this FRAG to be the prev of the next FRAG.
   Previous->Next = this;                           // This FRAG is after the FRAG before it, inform other FRAGs!
   Next->Previous = this;                           // This FRAG is before the one after it, inform other FRAGs!
   //printf("I attached FRAG %d to %d!\n", data, Previous->data);
};

void FRAG::IsNowBefore(FRAG* p) {
   Previous       = p->Previous;                    // Set the prev of this FRAG to be the prev of the FRAG to we're replacing.
   Next           = p;                              // Set the next of this FRAG to be the next of the prev FRAG.
   Previous->Next = this;                           // This FRAG is after the FRAG before it, inform other FRAGs!
   p->Previous    = this;                           // This FRAG is before the one after it, inform other FRAGs!
   //printf("I attached FRAG %d to %d!\n", data, Previous->data);
};

void FRAG::IsNowBeforeSafe(FRAG* p) {
   Previous       = p->Previous;                    // Set the prev of this FRAG to be the prev of the FRAG to we're replacing.
   Next           = Previous->Next;                 // Set the next of this FRAG to be the next of the prev FRAG.
   Previous->Next = this;                           // This FRAG is after the FRAG before it, inform other FRAGs!
   Next->Previous = this;                           // This FRAG is before the one after it, inform other FRAGs!
   //printf("I attached FRAG %d to %d!\n", data, Previous->data);
};

void FRAG::Detach(void) {
   Previous->Next  = Next;
   Next->Previous  = Previous;
   Next = Previous = this;
   FRAG::number--;
};

void FRAG::ClearList(void) {
   while (!FRAG::top->Next->header) delete FRAG::top->Next;
};
