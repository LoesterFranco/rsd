// Copyright 2019- RSD contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.


//
// --- Types related to debug.
//


package DebugTypes;

import BasicTypes::*;
import MemoryMapTypes::*;
import OpFormatTypes::*;
import MicroOpTypes::*;
import RenameLogicTypes::*;
import SchedulerTypes::*;
import LoadStoreUnitTypes::*;
import PipelineTypes::*;

//
// --- Hardware Counter
//

// ハードウェアカウンタ用のアドレス範囲
// アドレスの上位 HARDWARE_COUNTER_TAG_BIT_SIZE ビットが
// HARDWARE_COUNTER_TAG と一致したら、ハードウェアカウンタ用アドレス
localparam HARDWARE_COUNTER_TAG = 5'b11111; // addr: f8000000-ffffffff
localparam HARDWARE_COUNTER_TAG_BIT_SIZE = 5;
localparam HARDWARE_COUNTER_TAG_MSB = DATA_WIDTH - 1;
localparam HARDWARE_COUNTER_TAG_LSB =
    HARDWARE_COUNTER_TAG_MSB - HARDWARE_COUNTER_TAG_BIT_SIZE + 1;

// ハードウェアカウンタの種類を指定するビットの指定
localparam HARDWARE_COUNTER_TYPE_BIT_SIZE = 3;
localparam HARDWARE_COUNTER_TYPE_LSB = DATA_BYTE_WIDTH_BIT_SIZE;
localparam HARDWARE_COUNTER_TYPE_MSB =
    HARDWARE_COUNTER_TYPE_LSB + HARDWARE_COUNTER_TYPE_BIT_SIZE - 1;

// 各種ハードウェアカウンタ
typedef enum logic [ HARDWARE_COUNTER_TYPE_BIT_SIZE-1:0 ] {
    HW_CNT_TYPE_CYCLE = 0,
    HW_CNT_TYPE_COMMIT = 1,
    HW_CNT_TYPE_REFETCH_THIS_PC = 2,
    HW_CNT_TYPE_REFETCH_NEXT_PC = 3,
    HW_CNT_TYPE_REFETCH_BR_TARGET = 4,
    HW_CNT_TYPE_LOAD_MISS = 5
} HardwareCounterType;

//
// --- Debug Register
//

typedef struct packed { // NextPCStageDebugRegister
    logic valid;
    OpSerial sid;
} NextPCStageDebugRegister;

typedef struct packed { // FetchStageDebugRegister
    logic valid;
    OpSerial sid;
    logic flush;
} FetchStageDebugRegister;

typedef struct packed { // PreDecodeStageDebugRegister
    logic valid;
    OpSerial sid;
`ifdef RSD_FUNCTIONAL_SIMULATION
    // 演算のソースと結果の値は、機能シミュレーション時のみデバッグ出力する
    // 合成時は、IOポートが足りなくて不可能であるため
    IntALU_Code aluCode;
    IntMicroOpSubType opType;
`endif
} PreDecodeStageDebugRegister;

typedef struct packed { // DecodeStageDebugRegister
    logic valid;
    logic flush;    // Branch misprediction is detected on instruction decode and flush this instruction.
    OpId opId;
    AddrPath pc;
    InsnPath insn;
    logic undefined;
    logic unsupported;
} DecodeStageDebugRegister;

typedef struct packed { // RenameStageDebugRegister
    logic valid;
    OpId opId;

    // Physical register numbers are outputed in the next stage, becuase
    // The pop flags of the free list is negated and correct physical
    // register numbers cannot be outputed in this stage when the pipeline
    // is stalled.
} RenameStageDebugRegister;

typedef struct packed { // DispatchStageDebugRegister
    logic valid;
    OpId opId;


`ifdef RSD_FUNCTIONAL_SIMULATION
    // レジスタ番号は、機能シミュレーション時のみデバッグ出力する
    // 合成時は、IOポートが足りなくて不可能であるため
    logic readRegA;
    LRegNumPath logSrcRegA;
    PRegNumPath phySrcRegA;

    logic readRegB;
    LRegNumPath logSrcRegB;
    PRegNumPath phySrcRegB;

    logic writeReg;
    LRegNumPath logDstReg;
    PRegNumPath phyDstReg;
    PRegNumPath phyPrevDstReg;

    IssueQueueIndexPath issueQueuePtr;
`endif
} DispatchStageDebugRegister;

typedef struct packed { // IntegerIssueStageDebugRegister
    logic valid;
    logic flush;
    OpId opId;
} IntegerIssueStageDebugRegister;

typedef struct packed { // IntegerRegisterReadStageDebugRegister
    logic valid;
    logic flush;
    OpId opId;
} IntegerRegisterReadStageDebugRegister;

typedef struct packed { // IntegerExecutionStageDebugRegister
    logic valid;
    logic flush;
    OpId opId;

`ifdef RSD_FUNCTIONAL_SIMULATION
    // 演算のソースと結果の値は、機能シミュレーション時のみデバッグ出力する
    // 合成時は、IOポートが足りなくて不可能であるため
    DataPath dataOut;
    DataPath fuOpA;
    DataPath fuOpB;
    IntALU_Code aluCode;
    IntMicroOpSubType opType;
`endif

} IntegerExecutionStageDebugRegister;

typedef struct packed { // IntegerRegisterWriteStageDebugRegister
    logic valid;
    logic flush;
    OpId opId;
} IntegerRegisterWriteStageDebugRegister;

typedef struct packed { // ComplexIntegerIssueStageDebugRegister
    logic valid;
    logic flush;
    OpId opId;
} ComplexIntegerIssueStageDebugRegister;

typedef struct packed { // ComplexIntegerRegisterReadStageDebugRegister
    logic valid;
    logic flush;
    OpId opId;
} ComplexIntegerRegisterReadStageDebugRegister;

typedef struct packed { // ComplexIntegerExecutionStageDebugRegister
    logic [ COMPLEX_EXEC_STAGE_DEPTH-1:0 ] valid;
    logic [ COMPLEX_EXEC_STAGE_DEPTH-1:0 ] flush;
    OpId [ COMPLEX_EXEC_STAGE_DEPTH-1:0 ] opId;

`ifdef RSD_FUNCTIONAL_SIMULATION
    // 演算のソースと結果の値は、機能シミュレーション時のみデバッグ出力する
    // 合成時は、IOポートが足りなくて不可能であるため
    DataPath dataOut;
    DataPath fuOpA;
    DataPath fuOpB;

    VectorPath vecDataOut;
    VectorPath fuVecOpA;
    VectorPath fuVecOpB;
`endif

} ComplexIntegerExecutionStageDebugRegister;

typedef struct packed { // ComplexIntegerRegisterWriteStageDebugRegister
    logic valid;
    logic flush;
    OpId opId;
} ComplexIntegerRegisterWriteStageDebugRegister;

typedef struct packed { // MemoryIssueStageDebugRegister
    logic valid;
    logic flush;
    OpId opId;
} MemoryIssueStageDebugRegister;

typedef struct packed { // MemoryRegisterReadStageDebugRegister
    logic valid;
    logic flush;
    OpId opId;
} MemoryRegisterReadStageDebugRegister;

typedef struct packed { // MemoryExecutionStageDebugRegister
    logic valid;
    logic flush;
    OpId opId;

`ifdef RSD_FUNCTIONAL_SIMULATION
    // 演算のソースと結果の値は、機能シミュレーション時のみデバッグ出力する
    // 合成時は、IOポートが足りなくて不可能であるため
    AddrPath addrOut;
    DataPath fuOpA;
    DataPath fuOpB;
    VectorPath fuVecOpB;
    MemMicroOpSubType opType;
    MemAccessSizeType size;
    logic isSigned;
`endif

} MemoryExecutionStageDebugRegister;

typedef struct packed { // MemoryTagAccessStageDebugRegister
    logic valid;
    logic flush;
    OpId opId;
`ifdef RSD_FUNCTIONAL_SIMULATION
    logic executeLoad;
    AddrPath executedLoadAddr;
    logic executeStore;
    AddrPath executedStoreAddr;
    DataPath executedStoreData;
    VectorPath executedStoreVectorData;
`endif
} MemoryTagAccessStageDebugRegister;

typedef struct packed { // MemoryAccessStageDebugRegister
    logic valid;
    logic flush;
    OpId opId;
`ifdef RSD_FUNCTIONAL_SIMULATION
    logic executeLoad;
    DataPath executedLoadData;
    VectorPath executedLoadVectorData;
`endif
} MemoryAccessStageDebugRegister;

typedef struct packed { // MemoryRegisterWriteStageDebugRegister
    logic valid;
    logic flush;
    OpId opId;
} MemoryRegisterWriteStageDebugRegister;

typedef struct packed { // CommitStageDebugRegister
    logic commit;
    logic flush;
    OpId opId;

`ifdef RSD_FUNCTIONAL_SIMULATION
    logic releaseReg;
    PRegNumPath phyReleasedReg;
`endif
} CommitStageDebugRegister;

typedef struct packed { // ActiveListDebugRegister
    logic finished;
    OpId opId;
} ActiveListDebugRegister;

typedef struct packed { // SchedulerDebugRegister
    logic valid;
} SchedulerDebugRegister;

typedef struct packed { // IssueQueueDebugRegister
    logic flush;
    OpId opId;
} IssueQueueDebugRegister;


`ifndef RSD_DISABLE_DEBUG_REGISTER
typedef struct packed { // DebugRegister

    // DebugRegister of each stage
    NextPCStageDebugRegister [ FETCH_WIDTH-1:0 ] npReg;
    FetchStageDebugRegister   [ FETCH_WIDTH-1:0 ] ifReg;
    PreDecodeStageDebugRegister[ DECODE_WIDTH-1:0 ]   pdReg;
    DecodeStageDebugRegister   [ DECODE_WIDTH-1:0 ]   idReg;
    RenameStageDebugRegister   [ RENAME_WIDTH-1:0 ]   rnReg;
    DispatchStageDebugRegister [ DISPATCH_WIDTH-1:0 ] dsReg;

    IntegerIssueStageDebugRegister         [ INT_ISSUE_WIDTH-1:0 ] intIsReg;
    IntegerRegisterReadStageDebugRegister  [ INT_ISSUE_WIDTH-1:0 ] intRrReg;
    IntegerExecutionStageDebugRegister     [ INT_ISSUE_WIDTH-1:0 ] intExReg;
    IntegerRegisterWriteStageDebugRegister [ INT_ISSUE_WIDTH-1:0 ] intRwReg;

`ifndef RSD_MARCH_UNIFIED_MULDIV_MEM_PIPE
    ComplexIntegerIssueStageDebugRegister         [ COMPLEX_ISSUE_WIDTH-1:0 ] complexIsReg;
    ComplexIntegerRegisterReadStageDebugRegister  [ COMPLEX_ISSUE_WIDTH-1:0 ] complexRrReg;
    ComplexIntegerExecutionStageDebugRegister     [ COMPLEX_ISSUE_WIDTH-1:0 ] complexExReg;
    ComplexIntegerRegisterWriteStageDebugRegister [ COMPLEX_ISSUE_WIDTH-1:0 ] complexRwReg;
`endif

    MemoryIssueStageDebugRegister          [ MEM_ISSUE_WIDTH-1:0 ] memIsReg;
    MemoryRegisterReadStageDebugRegister   [ MEM_ISSUE_WIDTH-1:0 ] memRrReg;
    MemoryExecutionStageDebugRegister      [ MEM_ISSUE_WIDTH-1:0 ] memExReg;
    MemoryTagAccessStageDebugRegister      [ MEM_ISSUE_WIDTH-1:0 ] mtReg;
    MemoryAccessStageDebugRegister         [ MEM_ISSUE_WIDTH-1:0 ] maReg;
    MemoryRegisterWriteStageDebugRegister  [ MEM_ISSUE_WIDTH-1:0 ] memRwReg;

    CommitStageDebugRegister [ COMMIT_WIDTH-1:0 ] cmReg;

    SchedulerDebugRegister  [ ISSUE_QUEUE_ENTRY_NUM-1:0 ] scheduler;
    IssueQueueDebugRegister [ ISSUE_QUEUE_ENTRY_NUM-1:0 ] issueQueue;

    // Signals related to commit
    logic toRecoveryPhase;
    ActiveListIndexPath activeListHeadPtr;
    ActiveListCountPath activeListCount;

    // Pipeline control signal
    PipelineControll npStagePipeCtrl;
    PipelineControll ifStagePipeCtrl;
    PipelineControll pdStagePipeCtrl;
    PipelineControll idStagePipeCtrl;
    PipelineControll rnStagePipeCtrl;
    PipelineControll dsStagePipeCtrl;
    PipelineControll backEndPipeCtrl;
    PipelineControll cmStagePipeCtrl;
    logic stallByDecodeStage;

    // Others
    logic loadStoreUnitAllocatable;
    logic storeCommitterPhase;
    StoreQueueCountPath storeQueueCount;
    logic busyInRecovery;
    logic storeQueueEmpty;
} DebugRegister;
`else
    // Dummy definition
    typedef logic DebugRegister;
`endif

endpackage
