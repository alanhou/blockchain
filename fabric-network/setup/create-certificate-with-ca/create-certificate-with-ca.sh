createcertificatesForOrg1() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p crypto-config-ca/peerOrganizations/org1.alanhou.org/
  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca.org1.alanhou.org --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1-alanhou-org.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1-alanhou-org.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1-alanhou-org.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1-alanhou-org.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/msp/config.yaml

  echo
  echo "Register peer0"
  echo
  fabric-ca-client register --caname ca.org1.alanhou.org --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  echo
  echo "Register peer1"
  echo
  fabric-ca-client register --caname ca.org1.alanhou.org --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  echo
  echo "Register user"
  echo
  fabric-ca-client register --caname ca.org1.alanhou.org --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  echo
  echo "Register the org admin"
  echo
  fabric-ca-client register --caname ca.org1.alanhou.org --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  mkdir -p crypto-config-ca/peerOrganizations/org1.alanhou.org/peers

  # -----------------------------------------------------------------------------------
  #  Peer 0
  mkdir -p crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer0.org1.alanhou.org

  echo
  echo "## Generate the peer0 msp"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.org1.alanhou.org -M ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer0.org1.alanhou.org/msp --csr.hosts peer0.org1.alanhou.org --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer0.org1.alanhou.org/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca.org1.alanhou.org -M ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer0.org1.alanhou.org/tls --enrollment.profile tls --csr.hosts peer0.org1.alanhou.org --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer0.org1.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer0.org1.alanhou.org/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer0.org1.alanhou.org/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer0.org1.alanhou.org/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer0.org1.alanhou.org/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer0.org1.alanhou.org/tls/server.key

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer0.org1.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/msp/tlscacerts/ca.crt

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/tlsca
  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer0.org1.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/tlsca/tlsca.org1.alanhou.org-cert.pem

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/ca
  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer0.org1.alanhou.org/msp/cacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/ca/ca.org1.alanhou.org-cert.pem

  # ------------------------------------------------------------------------------------------------

  # Peer1

  mkdir -p crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer1.org1.alanhou.org

  echo
  echo "## Generate the peer1 msp"
  echo
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca.org1.alanhou.org -M ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer1.org1.alanhou.org/msp --csr.hosts peer1.org1.alanhou.org --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer1.org1.alanhou.org/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca.org1.alanhou.org -M ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer1.org1.alanhou.org/tls --enrollment.profile tls --csr.hosts peer1.org1.alanhou.org --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer1.org1.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer1.org1.alanhou.org/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer1.org1.alanhou.org/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer1.org1.alanhou.org/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer1.org1.alanhou.org/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/peers/peer1.org1.alanhou.org/tls/server.key

  # --------------------------------------------------------------------------------------------------

  mkdir -p crypto-config-ca/peerOrganizations/org1.alanhou.org/users
  mkdir -p crypto-config-ca/peerOrganizations/org1.alanhou.org/users/User1@org1.alanhou.org

  echo
  echo "## Generate the user msp"
  echo
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca.org1.alanhou.org -M ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/users/User1@org1.alanhou.org/msp --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  mkdir -p crypto-config-ca/peerOrganizations/org1.alanhou.org/users/Admin@org1.alanhou.org

  echo
  echo "## Generate the org admin msp"
  echo
  fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7054 --caname ca.org1.alanhou.org -M ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/users/Admin@org1.alanhou.org/msp --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/org1.alanhou.org/users/Admin@org1.alanhou.org/msp/config.yaml

}

# createcertificatesForOrg1

createCertificateForOrg2() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p /crypto-config-ca/peerOrganizations/org2.alanhou.org/

  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca.org2.alanhou.org --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2-alanhou-org.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2-alanhou-org.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2-alanhou-org.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-org2-alanhou-org.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.org2.alanhou.org --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  echo
  echo "Register peer1"
  echo
   
  fabric-ca-client register --caname ca.org2.alanhou.org --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.org2.alanhou.org --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.org2.alanhou.org --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  mkdir -p crypto-config-ca/peerOrganizations/org2.alanhou.org/peers
  mkdir -p crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer0.org2.alanhou.org

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.org2.alanhou.org -M ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer0.org2.alanhou.org/msp --csr.hosts peer0.org2.alanhou.org --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer0.org2.alanhou.org/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca.org2.alanhou.org -M ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer0.org2.alanhou.org/tls --enrollment.profile tls --csr.hosts peer0.org2.alanhou.org --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer0.org2.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer0.org2.alanhou.org/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer0.org2.alanhou.org/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer0.org2.alanhou.org/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer0.org2.alanhou.org/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer0.org2.alanhou.org/tls/server.key

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer0.org2.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/msp/tlscacerts/ca.crt

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/tlsca
  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer0.org2.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/tlsca/tlsca.org2.alanhou.org-cert.pem

  mkdir ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/ca
  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer0.org2.alanhou.org/msp/cacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/ca/ca.org2.alanhou.org-cert.pem

  # --------------------------------------------------------------------------------
  #  Peer 1
  echo
  echo "## Generate the peer1 msp"
  echo
   
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca.org2.alanhou.org -M ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer1.org2.alanhou.org/msp --csr.hosts peer1.org2.alanhou.org --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer1.org2.alanhou.org/msp/config.yaml

  echo
  echo "## Generate the peer1-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca.org2.alanhou.org -M ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer1.org2.alanhou.org/tls --enrollment.profile tls --csr.hosts peer1.org2.alanhou.org --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer1.org2.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer1.org2.alanhou.org/tls/ca.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer1.org2.alanhou.org/tls/signcerts/* ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer1.org2.alanhou.org/tls/server.crt
  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer1.org2.alanhou.org/tls/keystore/* ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/peers/peer1.org2.alanhou.org/tls/server.key
  # -----------------------------------------------------------------------------------

  mkdir -p crypto-config-ca/peerOrganizations/org2.alanhou.org/users
  mkdir -p crypto-config-ca/peerOrganizations/org2.alanhou.org/users/User1@org2.alanhou.org

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca.org2.alanhou.org -M ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/users/User1@org2.alanhou.org/msp --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  mkdir -p crypto-config-ca/peerOrganizations/org2.alanhou.org/users/Admin@org2.alanhou.org

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://org2admin:org2adminpw@localhost:8054 --caname ca.org2.alanhou.org -M ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/users/Admin@org2.alanhou.org/msp --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/msp/config.yaml ${PWD}/crypto-config-ca/peerOrganizations/org2.alanhou.org/users/Admin@org2.alanhou.org/msp/config.yaml

}

# createCertificateForOrg2

createCretificateForOrderer() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p crypto-config-ca/ordererOrganizations/alanhou.org

  export FABRIC_CA_CLIENT_HOME=${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/msp/config.yaml

  echo
  echo "Register orderer"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer2"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer2 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer3"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register the orderer admin"
  echo
   
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  mkdir -p crypto-config-ca/ordererOrganizations/alanhou.org/orderers
  # mkdir -p crypto-config-ca/ordererOrganizations/alanhou.org/orderers/alanhou.org

  # ---------------------------------------------------------------------------
  #  Orderer

  mkdir -p crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org/msp --csr.hosts orderer.alanhou.org --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org/tls --enrollment.profile tls --csr.hosts orderer.alanhou.org --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org/msp/tlscacerts/tlsca.alanhou.org-cert.pem

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/msp/tlscacerts/tlsca.alanhou.org-cert.pem

  # -----------------------------------------------------------------------
  #  Orderer 2

  mkdir -p crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer2.alanhou.org

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer2.alanhou.org/msp --csr.hosts orderer2.alanhou.org --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer2.alanhou.org/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer2.alanhou.org/tls --enrollment.profile tls --csr.hosts orderer2.alanhou.org --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer2.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer2.alanhou.org/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer2.alanhou.org/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer2.alanhou.org/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer2.alanhou.org/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer2.alanhou.org/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer2.alanhou.org/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer2.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer2.alanhou.org/msp/tlscacerts/tlsca.alanhou.org-cert.pem

  # mkdir ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/msp/tlscacerts
  # cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer2.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/msp/tlscacerts/tlsca.alanhou.org-cert.pem

  # ---------------------------------------------------------------------------
  #  Orderer 3
  mkdir -p crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer3.alanhou.org

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer3.alanhou.org/msp --csr.hosts orderer3.alanhou.org --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer3.alanhou.org/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer3.alanhou.org/tls --enrollment.profile tls --csr.hosts orderer3.alanhou.org --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer3.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer3.alanhou.org/tls/ca.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer3.alanhou.org/tls/signcerts/* ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer3.alanhou.org/tls/server.crt
  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer3.alanhou.org/tls/keystore/* ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer3.alanhou.org/tls/server.key

  mkdir ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer3.alanhou.org/msp/tlscacerts
  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer3.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer3.alanhou.org/msp/tlscacerts/tlsca.alanhou.org-cert.pem

  # mkdir ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/msp/tlscacerts
  # cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/orderers/orderer3.alanhou.org/tls/tlscacerts/* ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/msp/tlscacerts/tlsca.alanhou.org-cert.pem

  # ---------------------------------------------------------------------------

  mkdir -p crypto-config-ca/ordererOrganizations/alanhou.org/users
  mkdir -p crypto-config-ca/ordererOrganizations/alanhou.org/users/Admin@alanhou.org

  echo
  echo "## Generate the admin msp"
  echo
   
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/users/Admin@alanhou.org/msp --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/msp/config.yaml ${PWD}/crypto-config-ca/ordererOrganizations/alanhou.org/users/Admin@alanhou.org/msp/config.yaml

}

# createCretificateForOrderer

sudo rm -rf crypto-config-ca/*
# sudo rm -rf fabric-ca/*
createcertificatesForOrg1
createCertificateForOrg2
createCretificateForOrderer

