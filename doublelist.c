#include "doublelist.h"

doublelist* newdoublelist(char blank);
void write(doublelist *pt, char x);
char get_current(doublelist *pt);
int move(doublelist *pt, movement move);
void printlist(doublelist * pt);
void printlistfrom(doublelist * pt, int pos);
int write_string(doublelist * pt, string s);
void printxlist(doublelist * pt, int x);


/*
int main(void){
    doublelist * d = newdoublelist('B');

    printlist(d);
    write_string(d, "hola_micus");
    printlist(d);
    printf("get_current: %c\n", get_current(d));

    printxlist(d, 2);
    return 0;
}
*/

doublelist* newdoublelist(char blank){
    doublelist * d = malloc(sizeof(doublelist));
    if (d == NULL)
        return NULL;

    d->list = malloc(sizeof(char) * DEFAULT_LIST_SIZE);
    if ( d->list == NULL){
        free(d);
        return NULL;
    }

    d->size = DEFAULT_LIST_SIZE;
    d->current = ( DEFAULT_LIST_SIZE / 2 );

    d->blank = blank;

    memset(d->list, blank, DEFAULT_LIST_SIZE);

    return d;
}

void write(doublelist *pt, char x){
    pt->list[pt->current] = x;
}

char get_current(doublelist *pt){
    return pt->list[pt->current];
}

int move(doublelist *pt, movement move){
    if ( move == RIGHT){
        if ( pt->current == pt->size - 1){
            pt->list = realloc(pt->list, pt->size + DEFAULT_LIST_ADDITION);
            if ( pt->list == NULL){
                printf("Couldn't add size to the list\n");
                return -1;
            }
            memset(pt->list + pt->size, pt->blank, DEFAULT_LIST_ADDITION);
            pt->size += DEFAULT_LIST_ADDITION;
        }
        pt->current++;
    }
    else {
        if ( move == LEFT ){
            if ( pt->current == 0){
                pt->list = realloc(pt->list, pt->size + DEFAULT_LIST_ADDITION);
                if ( pt->list == NULL){
                    printf("Couldn't add size to the list\n");
                    return -1;
                }
                memcpy(pt->list + DEFAULT_LIST_ADDITION, pt->list, pt->size);
                memset(pt->list, pt->blank, DEFAULT_LIST_ADDITION);
                pt->size += DEFAULT_LIST_ADDITION; 
                pt->current = DEFAULT_LIST_ADDITION;
            }
            
        pt->current--;
        }
    }
    return 0;
}

void printlist(doublelist * pt){
    printlistfrom(pt, 0);
}

void printlistfrom(doublelist * pt, int pos){
    if ( pos < pt->size){
        for ( int i = pos; i < pt->size; i++){
            printf(" %c", pt->list[i]);
        }
        putchar('\n');
        
        for ( int i = pos; i < pt->current; i++){
            putchar(' ');
            putchar(' ');
        }
        printf("↑\n");
    }
    else {
        printf("Position cannot be larger than the list size");
    }
    
}

void printxlist(doublelist * pt, int x){
    for ( int i = 0; i < x; i++){
        int p = pt->current - x + i;
        printf(" %c", (p < 0)? pt->blank : pt->list[p]);
    }
    printf(" %c", pt->list[pt->current]);
    for ( int i = 0; i < x; i++){
        int p = pt->current + 1 + i;
        printf(" %c", (p >= pt->size - 1)? pt->blank : pt->list[p]);
    }
    putchar('\n');

    for ( int i = 0; i < x; i++){
        putchar(' ');
        putchar(' ');
    }
    printf("↑\n");
}

int write_string(doublelist * pt, string s){
    int length = strlen(s);

    for ( int i = 0; i < length; i++){
        write(pt, s[i]);
        if ( move(pt, RIGHT) == -1)
            return -1;
    }

    for ( int i = 0; i < length; i++){
        if ( move(pt, LEFT) )
            return -1;
    }
    return 0;
        
}
