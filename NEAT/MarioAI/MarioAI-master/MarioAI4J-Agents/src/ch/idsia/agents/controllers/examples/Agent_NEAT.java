package ch.idsia.agents.controllers.examples;

import java.util.ArrayList;
import java.util.Random;
import java.util.concurrent.ExecutionException;

import ch.idsia.agents.AgentOptions;
import ch.idsia.agents.IAgent;
import ch.idsia.agents.controllers.MarioHijackAIBase;
import ch.idsia.benchmark.mario.MarioSimulator;
import ch.idsia.benchmark.mario.engine.generalization.EntityType;
import ch.idsia.benchmark.mario.engine.generalization.Tile;
import ch.idsia.benchmark.mario.engine.input.MarioInput;
import ch.idsia.benchmark.mario.options.FastOpts;
import com.mathworks.engine.EngineException;
import com.mathworks.engine.MatlabEngine;

/**
 * Usage:
 * Add  matlabroot/bin/<arch> as environment variable
 * Run "matlab.engine.shareEngine" in matlab console to share session
 * Run Agent_NEAT
 *
 * Further Details see mathworks.com/help/matlab/matlab_external/setup-environment.html
 **/

public class Agent_NEAT extends MarioHijackAIBase implements IAgent {

	static MatlabEngine eng;

	@Override
	public void reset(AgentOptions options) {
		super.reset(options);
	}

	@Override
	public MarioInput actionSelectionAI() {
		control.jump();
		control.runRight();

		try {
			//eng.putVariable("gameState", new double[]{1.9, 2.9, 3.4, 3.5});

			/*Double enteties = new Double(e.entities.size());
			for (int i = 0; i < e.entities.size(); i++) {
				if(e.entities.get(i).type.equals(EntityType.DANGER))
			}*/

			double[] tiles = new double[t.tileField.length * t.tileField[1].length];
			int index = 0;
			for (int i = 0; i < t.tileField.length; i++) {
				for (int j = 0; j < t.tileField[i].length; j++) {
					tiles[index++] = (double) t.tileField[i][j].getCode();
				}
			}

			eng.putVariable("gameState_tiles", tiles);

		} catch (Exception e) {
			e.printStackTrace();
		}

		return action;
	}


	public static void main(String[] args) throws Exception {
		// USE WORLD WITH NON-FLAT GROUND WITHOUT ENEMIES

		closeMatlabEngineOnManualExit();

		String options = FastOpts.VIS_ON_2X + FastOpts.LEVEL_04_BLOCKS;
		MarioSimulator simulator = new MarioSimulator(options);
		IAgent agent = new Agent_NEAT();

		eng = MatlabEngine.connectMatlab(MatlabEngine.findMatlab()[0]);
		eng.eval("neat_network()");

		eng.putVariable("isTraining", true);
		for (int i = 0; i < 10; i++) {
			eng.putVariable("newSimulationStarted", true);
			simulator.run(agent);
			//todo simulation finished update fitness
		}

		eng.close();
		System.exit(0);


	}

	private static void closeMatlabEngineOnManualExit() {
		Runtime.getRuntime().addShutdownHook(new Thread() {
			public void run() {
				try {
					eng.close();
				} catch (EngineException e1) {
					e1.printStackTrace();
				}
			}
		});
	}
}
