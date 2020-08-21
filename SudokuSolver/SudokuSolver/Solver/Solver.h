
#ifndef Solver_h
#define Solver_h

#ifdef __cplusplus
extern "C" {
#endif

typedef struct ValuePoint
{
    int row;
    int column;
    int value;
    #ifdef __cplusplus
    ValuePoint() {}
    
    ValuePoint(int row, int column, int value) {
        this->row = row;
        this->column = column;
        this->value = value;
    }
    #endif


} ValuePoint;

ValuePoint* solve(const ValuePoint* points, int length);

#ifdef __cplusplus
}
#endif

#endif /* Solver_h */
