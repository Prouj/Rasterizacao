import PlaygroundSupport
import SwiftUI

enum Object {
    case triangulo1
    case quadrado1
    case hexagono1
    case triangulo2
    case quadrado2
    case hexagono2
    case retas
}

struct Point: Equatable {
    let x: Int
    let y: Int
}

struct ChartView: View {
    
    private var data: [Point] = []
    
    private var dataFill: [Point] = []
    
    var object: Object
    
    @State private var matrixValue: CGFloat = 50
    
    var matrix: [[Int]] = [[]]
    
    var x = 0
    var y = 0

    init() {
        // Gera a matriz de resolução que inicialmente é 50 x 50
        for x in 0...49 {
            matrix.append([Int]())
            for y in 0...49 {
                matrix[x].append(0)
            }
        }
        
        //Aqui você pode escolher um polígono para aparecer
        object = .quadrado2
       
        
        //Chamado da função de geração do casco apartir do caso escolhido
        geraPontos(object: object)
    }
    
    mutating func geraPontos(object: Object) {
 
        var square: [[[Int]]] = []
        // Casos onde são setados os pontos das retas que formam os polígonos.
        switch object {
        case .triangulo1:
            let reta1: [[Int]] = [[0,0],[25,50]]
            let reta2: [[Int]] = [[50,0],[25,50]]
            let reta3: [[Int]] = [[0,0],[50,0]]
            square = [reta1, reta2, reta3]
        case .quadrado1:
            let reta1: [[Int]] = [[0,0],[25,0]]
            let reta2: [[Int]] = [[25,0],[25,25]]
            let reta3: [[Int]] = [[0,0],[0,25]]
            let reta4: [[Int]] = [[0,25],[26,25]]
            square = [reta1, reta2, reta3, reta4]
        case .hexagono1:
            let reta1: [[Int]] = [[10,0],[31,0]]
            let reta2: [[Int]] = [[30,0],[40,15]]
            let reta3: [[Int]] = [[40,15],[30,30]]
            let reta4: [[Int]] = [[11,0],[0,15]]
            let reta5: [[Int]] = [[0,15],[11,29]]
            let reta6: [[Int]] = [[10,29],[31,29]]
            square = [reta1,reta2,reta3,reta4,reta5,reta6]
        case .triangulo2:
            let reta1: [[Int]] = [[0,40],[40,40]]
            let reta2: [[Int]] = [[20,0],[0,40]]
            let reta3: [[Int]] = [[20,0],[40,40]]
            square = [reta1, reta2, reta3]
        case .quadrado2:
            let reta1: [[Int]] = [[10,0],[30,0]]
            let reta2: [[Int]] = [[30,0],[30,20]]
            let reta3: [[Int]] = [[10,0],[10,20]]
            let reta4: [[Int]] = [[10,20],[31,20]]
            square = [reta1, reta2, reta3, reta4]
        case .hexagono2:
            let reta1: [[Int]] = [[10,49],[31,49]]
            let reta2: [[Int]] = [[30,20],[40,35]]
            let reta3: [[Int]] = [[40,35],[30,50]]
            let reta4: [[Int]] = [[11,20],[0,35]]
            let reta5: [[Int]] = [[0,35],[11,49]]
            let reta6: [[Int]] = [[10,20],[31,20]]
            square = [reta1, reta2, reta3, reta4, reta5, reta6]
        case .retas:
            let reta1: [[Int]] = [[0,40],[40,40]]
            let reta2: [[Int]] = [[25,0],[25,25]]
            let reta3: [[Int]] = [[0,15],[11,29]]
            let reta4: [[Int]] = [[40,15],[30,30]]
            square = [reta1, reta2, reta3, reta4]
        }
        
        square.forEach { reta in
            var x1: Int
            var x2: Int
            var y1: Int
            var y2: Int
            
            var m: CGFloat
            var b: CGFloat
            
            var deltaX: CGFloat
            var deltaY: CGFloat
            
            let point1 = reta[0]
            let point2 = reta[1]
            
            x1 = point1[0]
            y1 = point1[1]
            x2 = point2[0]
            y2 = point2[1]
            
            // É calculado o deltaX e o deltaY.
            deltaX = CGFloat(x2 - x1)
            
            deltaY = CGFloat(y2 - y1)
            
            // Em seguida, é obtido o valor de m e b.
            m = (deltaX == 0) ? 0 : deltaY/deltaX
            b = CGFloat(CGFloat(y1) - m*CGFloat(x1))
            
            // Por fim, é adicionado o ponto inicial, e começa a interação responsável por adicionar no array data, os pontos que devem ser pintados e formam as retas e o casco do poligono.
            data.append(Point(x: Int(x1), y: Int(y1)))
            
            if(abs(deltaX) > abs(deltaY)) {
                // Caso sim, o loop será realizado passando por cada ponto x do gráfico, começando no x1, até que o valor de x1 < x2-1.
                while x1 < x2-1 {
                    x1 += 1
                    y1 = Int(m*CGFloat(x1) + b)
                    matrix[x1][y1] = 1
                    data.append(Point(x: Int(x1), y: Int(y1)))
                    
                }
                // A outra condição se dá quando o valor absoluto do deltaY é maior que o valor absoluto de deltaX.
            } else if(abs(deltaX) < abs(deltaY)) {
                // Nesse caso, o loop será realizado passando por cada ponto y do gráfico, começando no y1, até que o valor de y1 < y2-1.
                while y1 < y2-1 {
                    y1 += 1
                    x1 = (m == 0) ? x2 : Int((Float(y1) - Float(b))/Float(m))
                    matrix[x1][y1] = 1
                    data.append(Point(x: Int(x1), y: Int(y1)))
                    
                }
            }
        }
        //Por fim se não for o caso retas é chamada a função fillPoligon que faz o prenchemento do polígono
        if object != .retas {
            fillPoligon(lines: data)
        }
            
    }
    
    //Função onde é feita a varredura da matriz *matrix* e são identificados os pontos que formaram o fillData
    mutating func fillPoligon(lines: [Point]) {
       
        var x_start = 0
        var x_end = 0
        let width = Int(matrixValue)

        //Aqui se inicia a interação para geração dos pontos que serão preenchidos, aos quais ficarão no array dataFill. Nessa interação fazemos uma varredura na matriz da *matrix* onde analisamos quais linhas e colunas tem pelo menos dois pixels que compõem array *data* e assim são preenchidos os pontos que interligam esses pontos do casco do polígono.
        for line in 0...width-1  {
            x_start = -1
            x_end = -1
            for column in 0...width-1  {
                if self.matrix[line][column] as! Int == 1 {
                    x_start = column
                    break
                }
            }

            for column in (0...width-1).reversed()  {
                if self.matrix[line][column] as! Int == 1 {
                    x_end = column
                    break
                }
            }
            if x_start != -1 && x_end != -1 {
                for column in x_start..<x_end{
                    dataFill.append(Point(x: line, y: column))
                }
            }
        }
    }
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Stepper(value: $matrixValue, in: 50...100, step: 5) {
                        Text("Resolution: "+String(format: "%.0f x %.0f", matrixValue, matrixValue))
                            .font(.title2)
                    }
                }.padding()
            }.padding(.horizontal)
            
            ZStack {
                gridBody
                lineBody
            }.frame(width: 400, height: 400, alignment: .center)
        }
        
    }
    private var gridBody: some View {
        GeometryReader { geometry in
            Path { path in
                let xStepWidth = geometry.size.width / self.matrixValue
                let yStepWidth = geometry.size.height / self.matrixValue
                
                (0...Int(self.matrixValue)).forEach { index in
                    let y = CGFloat(index) * yStepWidth
                    path.move(to: .init(x: 0, y: y))
                    path.addLine(to: .init(x: geometry.size.width, y: y))
                }
                
                (0...Int(self.matrixValue)).forEach { index in
                    let x = CGFloat(index) * xStepWidth
                    path.move(to: .init(x: x, y: 0))
                    path.addLine(to: .init(x: x, y: geometry.size.height))
                }
            }
            .stroke(Color.gray)
        }
    }
    
    private var lineBody: some View {
        ZStack {
            GeometryReader { geometry in
                Path { path in
                    let xStepWidth = geometry.size.width / matrixValue
                    let yStepWidth = geometry.size.height / matrixValue
                    
                    path.move(to: .init(x: 0, y: geometry.size.height))
                    self.data.forEach { point in
                        let x = (CGFloat(point.x) / self.matrixValue) * geometry.size.width
                        let y = geometry.size.height - (CGFloat(point.y) / self.matrixValue) * geometry.size.height
                        
                        let rect = CGRect(origin: CGPoint(x: x, y: y-yStepWidth), size: CGSize(width: xStepWidth, height: yStepWidth))
                        path.addRect(rect)
                    }
                }
                .fill(
                    Color.purple
                )
            }
            GeometryReader { geometry in
                Path { path in
                    let xStepWidth = geometry.size.width / matrixValue
                    let yStepWidth = geometry.size.height / matrixValue

                    path.move(to: .init(x: 0, y: geometry.size.height))
                    self.dataFill.forEach { point in
                        let x = (CGFloat(point.x) / self.matrixValue) * geometry.size.width
                        let y = geometry.size.height - (CGFloat(point.y) / self.matrixValue) * geometry.size.height

                        let rect = CGRect(origin: CGPoint(x: x, y: y-yStepWidth), size: CGSize(width: xStepWidth, height: yStepWidth))
                        path.addRect(rect)
                    }
                }
                .fill(
                    Color.purple
                )
            }
        }
    }
}
