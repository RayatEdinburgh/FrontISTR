//
//  FileReaderBoundaryNode.cpp
//
//
//
//                          2009.05.22
//                          2009.05.22
//                          k.Takeda
#include "FileReaderBoundaryNode.h"
using namespace FileIO;


CFileReaderBoundaryNode::CFileReaderBoundaryNode()
{
    ;
}

CFileReaderBoundaryNode::~CFileReaderBoundaryNode()
{
    ;
}

bool CFileReaderBoundaryNode::Read(ifstream& ifs, string& sLine)
{
    uiint bnode_id, node_id, dof;
    uiint mgLevel(0);
    uiint bnd_id, bnd_type, numOfBNode, mesh_id;
    double val, x, y, z;
    string s_bnd_type;
    
    istringstream iss;
    
    if(TagCheck(sLine, FileBlockName::StartBoundaryNode()) ){
        
        sLine = getLine(ifs);
        iss.clear();
        iss.str(sLine);

        // NodeBoundaryID, 境界種類, MeshID, 境界節点数
        iss >> bnd_id >> s_bnd_type >> mesh_id >> numOfBNode;

        // 境界タイプ文字列を uint に変換
        bnd_type= IntBndType(s_bnd_type);

        while(!ifs.eof()){
            sLine= getLine(ifs);
            if(TagCheck(sLine, FileBlockName::EndBoundaryNode())) break;
            iss.clear();
            iss.str(sLine);
            // BNodeID, NodeID, x, y, z, DOF, Value :=> x,y,z は未使用
            iss >> bnode_id >> node_id >> x >> y >> z >> dof >> val;

            mpFactory->GeneBoundaryNode(mgLevel, bnd_id, bnd_type, mesh_id, node_id, bnode_id, dof, val);
        };

        return true;
    }else{
        return false;
    }
}

bool CFileReaderBoundaryNode::Read_bin(ifstream& ifs)
{
    CFileReaderBinCheck *pBinCheck= CFileReaderBinCheck::Instance();
    bool bOrder= pBinCheck->isByteOrderSwap();

    //BinCheckのサイズ指定との整合性
    bool b32, bCheck;
    string sClassName("FileReaderBoundaryNode");

    if( !Check_IntSize(b32, bCheck, sClassName) ) return false;

    char cHead='B';
    if( !TagCheck_Bin(ifs, bCheck, cHead, FileBlockName::StartBoundaryNode(), FileBlockName::BoundaryNode_Len())) return false;

    uiint bnode_id, node_id, dof;
    uiint mgLevel(0);
    uiint bnd_id, bnd_type, nNumOfBNode, mesh_id;
    double val, x, y, z;
    string s_bnd_type;

    // NodeBoundaryID, 境界種類, MeshID, 境界節点数
    ifs.read((char*)&bnd_id, sizeof(uiint));  if(bOrder) pBinCheck->ByteOrderSwap(bnd_id);
    Read_BndType(ifs, s_bnd_type);
    ifs.read((char*)&mesh_id, sizeof(uiint));  if(bOrder) pBinCheck->ByteOrderSwap(mesh_id);
    ifs.read((char*)&nNumOfBNode, sizeof(uiint));  if(bOrder) pBinCheck->ByteOrderSwap(nNumOfBNode);

    // 境界タイプ文字列を uint に変換
    bnd_type= IntBndType(s_bnd_type);

    while(!ifs.eof()){
        if( CFileReader::Check_End(ifs) ) break;

        // BNodeID, NodeID, x, y, z, DOF, Value :=> x,y,z は未使用
        ifs.read((char*)&bnode_id, sizeof(uiint)); if(bOrder) pBinCheck->ByteOrderSwap(bnode_id);
        ifs.read((char*)&node_id, sizeof(uiint));  if(bOrder) pBinCheck->ByteOrderSwap(node_id);
        ifs.read((char*)&x, sizeof(double));  if(bOrder) pBinCheck->ByteOrderSwap(x);
        ifs.read((char*)&y, sizeof(double));  if(bOrder) pBinCheck->ByteOrderSwap(y);
        ifs.read((char*)&z, sizeof(double));  if(bOrder) pBinCheck->ByteOrderSwap(z);
        ifs.read((char*)&dof, sizeof(uiint));  if(bOrder) pBinCheck->ByteOrderSwap(dof);
        ifs.read((char*)&val, sizeof(double));  if(bOrder) pBinCheck->ByteOrderSwap(val);

        mpFactory->GeneBoundaryNode(mgLevel, bnd_id, bnd_type, mesh_id, node_id, bnode_id, dof, val);
    };

    return true;
}













